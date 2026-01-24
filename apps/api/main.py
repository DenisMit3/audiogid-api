import sys
import os

# Add the api directory to Python path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from api.index import app

# Vercel expects 'app' or 'handler'
