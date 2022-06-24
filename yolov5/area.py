import numpy as np
import cv2
import argparse
import glob

def getArea(
    source =''
):

    im = cv2.imread(source)
    imgray = cv2.cvtColor(im,cv2.COLOR_BGR2GRAY)
    equalized = cv2.equalizeHist(imgray)
    ret,thresh = cv2.threshold(imgray,127,255,0)
    
    contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)
    area = 0
    for cn in contours:
        area = cv2.contourArea(cn)
        if(area > 15000):
            area = area
            break
        

    print(area)
def parse_opt():
    parser = argparse.ArgumentParser()
    parser.add_argument('--source', type=str, default='', help='File from')
    opt = parser.parse_args()
    return opt



def main(opt):
    getArea(**vars(opt))


if __name__ == "__main__":
    opt = parse_opt()
    main(opt)