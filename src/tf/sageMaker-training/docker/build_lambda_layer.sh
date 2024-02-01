#!/bin/bash
PYTHONVERSION=$1
OUTPATH=./outputs/python/python/lib/$PYTHONVERSION/site-packages/
rm -r ./outputs/python/
mkdir $OUTPATH
# check this soln https://github.com/aws/sagemaker-python-sdk/issues/1200?ref=blog.ippon.fr#issuecomment-1720813527
pip install sagemaker --target $OUTPATH

rm -rf $OUTPATH/numpy*
rm -rf $OUTPATH/pandas*
rm -rf $OUTPATH/jsonschema*
pip install jsonschema==4.17.3 --target $OUTPATH

curl https://files.pythonhosted.org/packages/a5/37/d1453c9ff4f7630e68ec036c6fb56ba0d7c769daa8a4083cb4ef8ee45995/numpy-1.26.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -o outputs/numpy-1.26.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
unzip outputs/numpy-1.26.3-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -d $OUTPATH

curl https://files.pythonhosted.org/packages/b3/b3/3102c3a4abca1093e50cfec2213102a1c65c0b318a4431395d0121e6e690/pandas-2.2.0-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -o outputs/pandas-2.2.0-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl
unzip outputs/pandas-2.2.0-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl -d $OUTPATH

find $OUTPATH -type d -name "tests" -exec rm -rfv {} +
find $OUTPATH -type d -name "__pycache__" -exec rm -rfv {} +
