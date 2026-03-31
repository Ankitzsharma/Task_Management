from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional
import asyncio

import schemas, database, task_service

router = APIRouter(prefix="/tasks", tags=["tasks"])

@router.get("/", response_model=List[schemas.Task])
def read_tasks(
    title: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    db: Session = Depends(database.get_db)
):
    return task_service.get_tasks(db, title=title, status=status)

@router.post("/", response_model=schemas.Task)
async def create_task(task: schemas.TaskCreate, db: Session = Depends(database.get_db)):
    return task_service.create_task(db=db, task=task)

@router.put("/{task_id}", response_model=schemas.Task)
async def update_task(task_id: int, task: schemas.TaskUpdate, db: Session = Depends(database.get_db)):
    db_task = task_service.update_task(db=db, task_id=task_id, task_update=task)
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return db_task

@router.delete("/{task_id}")
def delete_task(task_id: int, db: Session = Depends(database.get_db)):
    db_task = task_service.delete_task(db=db, task_id=task_id)
    if db_task is None:
        raise HTTPException(status_code=404, detail="Task not found")
    return {"message": "Task deleted successfully"}
