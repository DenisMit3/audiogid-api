from passlib.context import CryptContext
import uuid

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# User 1: Juli / qwerty
hash1 = pwd_context.hash("qwerty")
uuid1 = str(uuid.uuid4())

# User 2: pometra / 01051982  
hash2 = pwd_context.hash("01051982")
uuid2 = str(uuid.uuid4())

print(f"INSERT INTO users (id, role, created_at, is_active, email, hashed_password) VALUES")
print(f"  ('{uuid1}', 'admin', NOW(), true, 'juli@audiogid.app', '{hash1}'),")
print(f"  ('{uuid2}', 'admin', NOW(), true, 'pometra@audiogid.app', '{hash2}');")
