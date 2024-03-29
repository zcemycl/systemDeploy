"""rename post table

Revision ID: bbbb2ad55cee
Revises: 695ce1267b3c
Create Date: 2024-03-18 00:35:11.000864

"""
from typing import Sequence, Union

import simple_auth
import sqlalchemy as sa
from alembic import op

# revision identifiers, used by Alembic.
revision: str = 'bbbb2ad55cee'
down_revision: Union[str, None] = '695ce1267b3c'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('post',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('title', sa.String(length=128), nullable=True),
    sa.Column('user', sa.Integer(), nullable=True),
    sa.ForeignKeyConstraint(['user'], ['users.id'], ),
    sa.PrimaryKeyConstraint('id')
    )
    op.drop_table('posts')
    # ### end Alembic commands ###


def downgrade() -> None:
    # ### commands auto generated by Alembic - please adjust! ###
    op.create_table('posts',
    sa.Column('id', sa.INTEGER(), autoincrement=True, nullable=False),
    sa.Column('title', sa.VARCHAR(length=128), autoincrement=False, nullable=True),
    sa.Column('user', sa.INTEGER(), autoincrement=False, nullable=True),
    sa.ForeignKeyConstraint(['user'], ['users.id'], name='posts_user_fkey'),
    sa.PrimaryKeyConstraint('id', name='posts_pkey')
    )
    op.drop_table('post')
    # ### end Alembic commands ###
