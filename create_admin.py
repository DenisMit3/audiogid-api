from sqlmodel import Session, select
from api.core.database import engine
from api.core.models import User
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

with Session(engine) as session:
    users = session.exec(select(User)).all()
    print(f"Found {len(users)} users")
    for u in users:
        print(f"  - {u.email or u.phone}, role={u.role}")
    
    admin = session.exec(select(User).where(User.email == "mit333@list.ru")).first()
    if admin:
        print(f"User exists: {admin.email}, role={admin.role}")
        admin.password_hash = pwd_context.hash("Solnyshko3")
        admin.role = "admin"
        session.add(admin)
        session.commit()
        print("Updated password and role to admin")
    else:
        admin = User(
            email="mit333@list.ru",
            password_hash=pwd_context.hash("Solnyshko3"),
            role="admin"
        )
        session.add(admin)
        session.commit()
        print(f"Created admin user: {admin.email}")
