from pydantic import BaseModel
from datetime import date
from typing import Optional
from enum import Enum

class TaskStatus(str, Enum):
    TODO = "To-Do"
    IN_PROGRESS = "In Progress"
    DONE = "Done"

class TaskBase(BaseModel):
    title: str
    description: Optional[str] = None
    due_date: date
    status: TaskStatus = TaskStatus.TODO
    blocked_by_id: Optional[int] = None

class TaskCreate(TaskBase):
    pass

class TaskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    due_date: Optional[date] = None
    status: Optional[TaskStatus] = None
    blocked_by_id: Optional[int] = None

class Task(TaskBase):
    id: int

    class Config:
        from_attributes = True
