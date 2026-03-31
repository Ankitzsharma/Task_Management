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

-   **Prompts Used**: The AI was prompted to generate the full-stack application based on the provided requirements, including the project structure, tech stack, and feature set.
-   **Example of Wrong AI Output and Fix**: Initially, the AI did not correctly implement the self-referencing foreign key in the SQLAlchemy model. The `blocked_by` relationship was corrected to properly link to the `id` of the `Task` model, ensuring the dependency tracking worked as expected.
