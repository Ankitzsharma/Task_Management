from sqlalchemy import Column, Integer, String, Date, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from database import Base
import enum

class TaskStatus(str, enum.Enum):
    TODO = "To-Do"
    IN_PROGRESS = "In Progress"
    DONE = "Done"

class Task(Base):
    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, index=True, nullable=False)
    description = Column(String, nullable=True)
    due_date = Column(Date, nullable=False)
    status = Column(SQLEnum(TaskStatus), default=TaskStatus.TODO, nullable=False)
    blocked_by_id = Column(Integer, ForeignKey("tasks.id"), nullable=True)

    # Self-referencing relationship
    blocked_by = relationship("Task", remote_side=[id], backref="blocking")
