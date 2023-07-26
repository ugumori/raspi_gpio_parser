from pydantic import BaseModel
from decimal import Decimal


class MotionModel(BaseModel):
    hw_id: str
    timestamp: Decimal
    motion: int
    pin: int
