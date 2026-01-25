import os

print("Pulling Preview Env...")
os.system("npx vercel env pull .env.preview --yes --environment=preview")

keys = []
try:
    with open('.env.preview') as f:
        for line in f:
            if '=' in line:
                k = line.split('=')[0]
                keys.append(k)
    print(f"Preview Keys: {keys}")
except Exception as e:
    print(e)
