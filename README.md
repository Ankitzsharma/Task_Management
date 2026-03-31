# Task Management Full-Stack App

## 1. Project Overview

This is a full-stack task management application built for a hiring assignment. The app allows users to create, read, update, and delete tasks. It features a Flutter-based frontend and a Python FastAPI backend, with data stored in a SQLite database.

## 2. Tech Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Riverpod
- **HTTP Client**: http
- **Backend**: Python FastAPI
- **ORM**: SQLAlchemy
- **Database**: SQLite

## 3. Setup Instructions

### Backend

1.  **Navigate to the `backend` directory:**
    ```bash
    cd backend
    ```

2.  **Create a virtual environment and activate it:**
    ```bash
    python -m venv venv
    source venv/bin/activate  # On Windows, use `venv\Scripts\activate`
    ```

3.  **Install the dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

4.  **Run the FastAPI server:**
    ```bash
    python -m uvicorn main:app --reload
    ```

    The backend will be running at `http://127.0.0.1:8000`.

### Frontend

1.  **Navigate to the `frontend` directory:**
    ```bash
    cd frontend
    ```

2.  **Install the dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app on an emulator or connected device:**
    ```bash
    flutter run
    ```

## 4. API Endpoints

-   `GET /tasks`: Fetches all tasks, with optional `title` and `status` query parameters for filtering.
-   `POST /tasks`: Creates a new task.
-   `PUT /tasks/{id}`: Updates an existing task.
-   `DELETE /tasks/{id}`: Deletes a task.

## 5. Features Implemented

-   **CRUD Functionality**: Full support for creating, reading, updating, and deleting tasks.
-   **Blocked Task UI**: Tasks that are blocked by another incomplete task are visually disabled.
-   **Draft Preservation**: Task creation progress is saved and restored if the user navigates away.
-   **Loading Indicators**: The UI provides feedback during network requests.
-   **Search and Filter**: Users can search for tasks by title and filter by status.

## 6. Track Selected

-   **Track A**

## 7. Stretch Goal

-   **Debounced Search**: The search input is debounced to avoid excessive API calls while typing.

## 8. AI Usage Report

AI tools (ChatGPT / coding assistants) were used as a **supportive tool** to accelerate development, not as a replacement for understanding or implementation.

### 🔹 How AI Was Used

* Assisted in **initial project scaffolding** (FastAPI routes, Flutter structure)
* Helped clarify **best practices for state management and API integration**
* Provided guidance on **UI improvements and UX patterns**
* Suggested approaches for handling **async operations and loading states**

All generated code was:

* Carefully reviewed
* Refactored where necessary
* Integrated manually into the project

---

### 🔹 Key Engineering Decisions (Human Contribution)

* Designed and implemented **task dependency logic (`blocked_by`)** using a self-referencing relational model
* Ensured **real-time UI updates after CRUD operations** by managing state refresh properly
* Fixed API integration issues (base URL mismatch, CORS handling)
* Improved UX by handling:

  * Loading states without UI freeze
  * Error handling with meaningful feedback
  * Draft persistence across navigation

---

### 🔹 Example of Incorrect AI Output & Fix

* **Issue:** AI initially generated an incorrect implementation for the `blocked_by` relationship in SQLAlchemy, which did not properly establish a self-referencing foreign key.
* **Fix:** Refactored the model to correctly reference the `Task.id`, ensuring proper dependency tracking and enabling accurate blocked task behavior in the UI.

Additionally:

* Resolved frontend API issues where tasks were not appearing due to incorrect base URL configuration (`10.0.2.2` vs `localhost`)
* Implemented proper data refetching after task creation to ensure UI consistency

---

### 🔹 Summary

AI was used to **speed up development and explore approaches**, but all critical logic, debugging, and integration decisions were made manually to ensure correctness, maintainability, and alignment with real-world application standards.

### 🔹 Created By Ankit Sharma