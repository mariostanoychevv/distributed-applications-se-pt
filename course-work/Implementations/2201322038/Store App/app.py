from fastapi import FastAPI, Depends, HTTPException, status, Request, Form, Cookie, File, UploadFile
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from fastapi.responses import HTMLResponse, RedirectResponse, JSONResponse
from fastapi.templating import Jinja2Templates
from jose import JWTError, jwt
from passlib.context import CryptContext
from datetime import datetime, timedelta
import mysql.connector
from urllib.parse import urlencode
import pandas as pd
import logging
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from dotenv import load_dotenv


app = FastAPI()
templates = Jinja2Templates(directory="templates")



def get_db():
    db = mysql.connector.connect(
        host="localhost",
        user="root",
        password="202018bby",
        database="ecommerce"
    )
    return db



SECRET_KEY = "your_secret_key"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30



pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")



class User:
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password



class Admin:
    def __init__(self, username: str, password: str):
        self.username = username
        self.password = password



def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)



def get_password_hash(password):
    return pwd_context.hash(password)



def create_access_token(data: dict, expires_delta: timedelta = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt



async def get_current_user(access_token: str = Cookie(None)):
    if access_token is None:
        raise HTTPException(status_code=401, detail="Not authenticated")
    try:
        token = access_token.split("Bearer ")[1]
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("SELECT * FROM admins WHERE username = %s", (username,))
    admin = cursor.fetchone()
    if admin:
        return {"id": admin["id"], "username": admin["username"], "is_admin": True}
    
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()
    if user:
        return {"id": user["id"], "username": user["username"], "is_admin": False}
    
    raise HTTPException(status_code=401, detail="User not found")
    
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    user = cursor.fetchone()
    if user is None:
        cursor.execute("SELECT * FROM admins WHERE username = %s", (username,))
        user = cursor.fetchone()
        if user is None:
            raise HTTPException(status_code=401, detail="User not found")
    return user



@app.get("/", response_class=HTMLResponse)
async def read_root(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})



@app.post("/register")
async def register(request: Request, username: str = Form(...), password: str = Form(...), is_admin: bool = Form(False)):
    db = get_db()
    cursor = db.cursor()
    
    cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
    user_exists = cursor.fetchone()

    cursor.execute("SELECT * FROM admins WHERE username = %s", (username,))
    admin_exists = cursor.fetchone()

    if user_exists or admin_exists:
        return templates.TemplateResponse("index.html", {"request": request, "register_error": "Username already taken"})

    hashed_password = get_password_hash(password)
    if is_admin:
        cursor.execute("INSERT INTO admins (username, password) VALUES (%s, %s)", (username, hashed_password))
    else:
        cursor.execute("INSERT INTO users (username, password) VALUES (%s, %s)", (username, hashed_password))
    
    db.commit()
    return RedirectResponse(url="/", status_code=303)



@app.post("/login")
async def login(request: Request, form_data: OAuth2PasswordRequestForm = Depends()):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("SELECT * FROM users WHERE username = %s", (form_data.username,))
    user = cursor.fetchone()

    if not user:
        cursor.execute("SELECT * FROM admins WHERE username = %s", (form_data.username,))
        user = cursor.fetchone()

    if not user or not verify_password(form_data.password, user["password"]):
        return templates.TemplateResponse("index.html", {"request": request, "login_error": "Wrong username or password"})

    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user["username"]}, expires_delta=access_token_expires
    )

    response = RedirectResponse(url="/menu", status_code=303)
    response.set_cookie(key="access_token", value=f"Bearer {access_token}", httponly=True)
    return response



@app.post("/logout")
async def logout():
    response = RedirectResponse(url="/", status_code=303)
    
    response.delete_cookie(key="access_token")
    
    return response



@app.get("/menu", response_class=HTMLResponse)
async def read_menu(request: Request, current_user: dict = Depends(get_current_user)):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    cursor.execute("SELECT * FROM products")
    products = cursor.fetchall()
    return templates.TemplateResponse("menu.html", {"request": request, "products": products, "is_admin": current_user.get("is_admin", False)})
# @app.get("/menu", response_class=HTMLResponse)
# async def read_menu(request: Request, current_user: dict = Depends(get_current_user)):
#     db = get_db()
#     cursor = db.cursor(dictionary=True)
#     cursor.execute("SELECT * FROM products")
#     products = cursor.fetchall()
#     return templates.TemplateResponse("menu.html", {"request": request, "products": products})



@app.post("/order/{product_id}")
async def create_order(product_id: str, quantity: int = Form(...), current_user: dict = Depends(get_current_user)):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    print(f"Attempting to order product with product_id: {product_id}")

    cursor.execute("SELECT * FROM products WHERE product_code = %s", (product_id,))
    product = cursor.fetchone()
    
    if product is None:
        raise HTTPException(status_code=404, detail="Product not found")
    
    # if product["quantity"] < quantity:
    #     raise HTTPException(status_code=400, detail="Not enough stock")
    
    total_price = product["price"] * quantity
    
    cursor.execute("INSERT INTO orders (user_id, product_id, quantity, price) VALUES (%s, %s, %s, %s)",
                   (current_user["id"], product_id, quantity, total_price))
    
    db.commit()
    
    return JSONResponse(status_code=200, content={"message": "Ordered successfully!"})



@app.get("/orders", response_class=HTMLResponse)
async def view_orders(request: Request, current_user: dict = Depends(get_current_user)):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    if current_user.get("username") in ["admin", "admin_username2"]:
        cursor.execute("""
            SELECT orders.order_id AS order_id, products.name, orders.quantity, orders.price, users.username 
            FROM orders 
            JOIN products ON orders.product_id = products.product_code 
            JOIN users ON orders.user_id = users.id
        """)
    else:
        cursor.execute("""
            SELECT orders.order_id AS order_id, products.name, orders.quantity, orders.price, products.quantity AS stock_quantity
            FROM orders 
            JOIN products ON orders.product_id = products.product_code 
            WHERE orders.user_id = %s
        """, (current_user["id"],))
    
    orders = cursor.fetchall()
    
    return templates.TemplateResponse("order.html", {"request": request, "orders": orders, "is_admin": current_user.get("username") in ["admin", "admin_username2"]})



@app.post("/orders/edit/{order_id}")
async def edit_order(
    order_id: str, 
    quantity: int = Form(...), 
    current_user: dict = Depends(get_current_user)
):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    if current_user.get("is_admin"):
        cursor.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
    else:
        cursor.execute("SELECT * FROM orders WHERE order_id = %s AND user_id = %s", (order_id, current_user["id"]))

    order = cursor.fetchone()
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    
    cursor.execute("SELECT * FROM products WHERE product_code = %s", (order["product_id"],))
    product = cursor.fetchone()
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")
    
    if product["quantity"] < quantity:
        raise HTTPException(status_code=400, detail="Not enough stock")
    
    total_price = product["price"]
    cursor.execute(""" 
        UPDATE orders 
        SET quantity = %s, price = %s 
        WHERE order_id = %s
    """, (quantity, total_price, order_id))
    db.commit()
    
    return RedirectResponse(url="/orders", status_code=303)



@app.post("/orders/delete/{order_id}")
async def delete_order(order_id: str, current_user: dict = Depends(get_current_user)):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    print(f"Attempting to delete order ID: {order_id} for user ID: {current_user['id']}")
    
    if current_user.get("is_admin"):
        cursor.execute("SELECT * FROM orders WHERE order_id = %s", (order_id,))
    else:
        cursor.execute("SELECT * FROM orders WHERE order_id = %s AND user_id = %s", (order_id, current_user["id"]))

    order = cursor.fetchone()
    if not order:
        print(f"Order not found or does not belong to the user")
        raise HTTPException(status_code=404, detail="Order not found")
    
    cursor.execute("DELETE FROM orders WHERE order_id = %s", (order_id,))
    db.commit()
    
    print(f"Order deleted successfully")
    return RedirectResponse(url="/orders", status_code=303)

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)



@app.post("/upload-products/")
async def upload_products(file: UploadFile = File(...), current_user: dict = Depends(get_current_user)):
        if not current_user.get("is_admin"):
            query_params = urlencode({"success": "You're not an administrator!"})
            return RedirectResponse(url="/menu?" + query_params, status_code=303)
        if not file.filename.endswith(".xlsx"):
            raise HTTPException(status_code=400, detail="Файлът трябва да бъде в Excel формат (.xlsx)")

        try:
            df = pd.read_excel(file.file, sheet_name="Sheet1")
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Грешка при четене на Excel файла: {str(e)}")

        db = get_db()
        cursor = db.cursor(dictionary=True)

        processed_products = []

        for index, row in df.iterrows():
            code = str(row.iloc[0])
            name = row.iloc[1]  # Колона B
            quantity = row.iloc[3]  # Колона D
            quantity = int(quantity)
            price = row.iloc[4]  # Колона E
            price = float(price)

            if not isinstance(quantity, (int, float)) or not isinstance(price, (int, float)):
                logger.warning(f"Пропуснат ред: невалидни данни за количество или цена. Ред: {row}")
                continue

            product_data = {
                "code": code,
                "name": name,
                "quantity": quantity,
                "price": price
            }
            processed_products.append(product_data)

            cursor.execute("SELECT * FROM products WHERE product_code = %s", (code,))
            existing_product = cursor.fetchone()

            if existing_product:
                try:
                    cursor.execute("""
                        UPDATE products
                        SET price = %s
                        WHERE product_code = %s
                    """, (price, code))
                    db.commit()
                    logger.info(f"Успешно актуализирана цена за продукт: {name}, Новата цена: {price}, Код: {code}")
                except mysql.connector.Error as e:
                    db.rollback()
                    logger.error(f"Грешка при актуализиране на цена за продукт: {str(e)}")
                    logger.error(f"Данни: name={name}, price={price}, code={code}")
            else:
                try:
                    cursor.execute("""
                        INSERT INTO products (name, quantity, price, product_code)
                        VALUES (%s, %s, %s, %s)
                    """, (name, quantity, price, code))
                    db.commit()
                    logger.info(f"Успешно вмъкнат продукт: {name}, Количество: {quantity}, Цена: {price}, Код: {code}")
                except mysql.connector.Error as e:
                    db.rollback()
                    logger.error(f"Грешка при вмъкване на продукт: {str(e)}")
                    logger.error(f"Данни: name={name}, quantity={quantity}, price={price}, code={code}")

        return {
            "message": "Продуктите бяха успешно обработени.",
            "processed_products": processed_products
        }


# load_dotenv()
# EMAIL_USER = os.getenv("EMAIL_USER")
# EMAIL_PASSWORD = os.getenv("EMAIL_PASSWORD")
# EMAIL_RECEIVER = os.getenv("EMAIL_RECEIVER")

# @app.post("/send-orders-email")
# async def send_orders_email(current_user: dict = Depends(get_current_user)):
#     if not current_user.get("is_admin"):
#         raise HTTPException(status_code=403, detail="Само администраторите могат да изпращат поръчки по имейл.")

#     try:
#         db = get_db()
#         cursor = db.cursor(dictionary=True)

#         cursor.execute("""
#             SELECT orders.order_id, products.name, orders.quantity, orders.price, users.username 
#             FROM orders 
#             JOIN products ON orders.product_id = products.product_code 
#             JOIN users ON orders.user_id = users.id
#         """)
#         orders = cursor.fetchall()

#         user_orders = {}
#         for order in orders:
#             username = order["username"]
#             if username not in user_orders:
#                 user_orders[username] = []
#             user_orders[username].append(order)

#         email_content = "Списък на поръчките по потребители:\n\n"
#         for username, orders in user_orders.items():
#             email_content += f"User: {username}\n"
#             for order in orders:
#                 email_content += f"- Продукт: {order['name']}, Брой стекове: {order['quantity']}, Цена: {order['price']}лв.\n"
#             email_content += "\n"

#         sender_email = EMAIL_USER
#         receiver_email = EMAIL_RECEIVER
#         password = EMAIL_PASSWORD

#         msg = MIMEMultipart()
#         msg['From'] = sender_email
#         msg['To'] = receiver_email
#         msg['Subject'] = "Списък на поръчките по потребители"
#         msg.attach(MIMEText(email_content, 'plain'))

#         with smtplib.SMTP('', 587) as server:
#             server.starttls()
#             server.login(sender_email, password)
#             server.sendmail(sender_email, receiver_email, msg.as_string())
        
#         logger.info("Имейлът беше изпратен успешно!")

#         cursor.execute("""
#             INSERT INTO finished_orders (user_id, product_id, quantity, price)
#             SELECT user_id, product_id, quantity, price FROM orders
#         """)
#         db.commit()

#         cursor.execute("DELETE FROM orders")
#         db.commit()

#         return {"message": "Поръчките бяха изпратени успешно по имейл и прехвърлени в finished_orders!"}
    
#     except Exception as e:
#         logger.error(f"Грешка при изпращане на имейла или прехвърляне на поръчките: {str(e)}")
#         db.rollback()
#         raise HTTPException(status_code=500, detail=f"Грешка: {str(e)}")



@app.get("/finished-orders", response_class=HTMLResponse)
async def view_finished_orders(request: Request, current_user: dict = Depends(get_current_user)):
    db = get_db()
    cursor = db.cursor(dictionary=True)

    cursor.execute("""
        SELECT finished_orders.order_id, products.name, finished_orders.quantity, finished_orders.price, finished_orders.order_date
        FROM finished_orders
        JOIN products ON finished_orders.product_id = products.product_code
        WHERE finished_orders.user_id = %s
    """, (current_user["id"],))
    
    finished_orders = cursor.fetchall()

    return templates.TemplateResponse("finished_orders.html", {"request": request, "finished_orders": finished_orders})


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app:app", host="localhost", port=8000, reload=True)