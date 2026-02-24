# Getting Started

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js (version X.X.X)
- npm (Node Package Manager) or yarn
- PostgreSQL (version X.X.X)
- Docker (if using Docker for mobile environment)

## Setup Instructions

### 1. Backend Setup

1. **Clone the Repository**  
   Open your terminal, navigate to your preferred directory, and run:
   ```bash
   git clone https://github.com/DenisMit3/audiogid-api.git
   cd audiogid-api
   ```

2. **Install Dependencies**  
   Run the following command to install the necessary dependencies:
   ```bash
   npm install
   ```

3. **Database Configuration**  
   Set up your PostgreSQL database. Create a `.env` file in the root directory and add:
   ```env
   DATABASE_URL=postgresql://user:password@localhost:5432/mydatabase
   ```

4. **Migrate Database**  
   Run the migration commands to set up your database schema:
   ```bash
   npm run migrate
   ```

5. **Start the Backend**  
   Start the backend server with:
   ```bash
   npm start
   ```

### 2. Mobile Setup

1. **Navigate to Mobile Directory**  
   Change directory to the mobile project:
   ```bash
   cd mobile
   ```

2. **Install Mobile Dependencies**  
   Use npm or yarn to install dependencies:
   ```bash
   npm install
   ``` 
   or  
   ```bash
   yarn install
   ```

3. **Run the Mobile Application**  
   To start the mobile app, run:
   ```bash
   npm start
   ```

### 3. Admin Panel Setup

1. **Navigate to Admin Panel Directory**  
   Change directory to the admin panel project:
   ```bash
   cd admin
   ```

2. **Install Admin Panel Dependencies**  
   Use npm or yarn to install dependencies:
   ```bash
   npm install
   ```  
   or  
   ```bash
   yarn install
   ```

3. **Run the Admin Panel**  
   To start the admin panel, run:
   ```bash
   npm start
   ```

### Common Commands

- **Run Tests**:  
  To run tests for the backend, use:
  ```bash
  npm test
  ```

- **Build for Production**:  
  For building the backend for production, run:
  ```bash
  npm run build
  ```

- **Docker Commands**: If using Docker, follow the commands:
  ```bash
  docker-compose up
  ```

## Conclusion

Follow these steps carefully to set up your backend, mobile, and admin panel environments. If you encounter issues, refer to the documentation in their respective directories for further assistance.
