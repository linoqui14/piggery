from sklearn.linear_model import LinearRegression
import pandas as pd
from sklearn.model_selection import train_test_split
import pickle
import argparse
import glob

def run(
    area = 0.0
):
    if area<10000:
        return

    filename = 'weigh_model.sav'
    loaded_model = pickle.load(open(filename, 'rb'))

    def calc(slope, intercept, area):
        return slope*area+intercept

    weight = calc(loaded_model.coef_, loaded_model.intercept_, area)
    print(loaded_model.predict([[area]])[0][0])

def parse_opt():
    parser = argparse.ArgumentParser()
    parser.add_argument('--area', type=float, default=0, help='Area of pig')
    opt = parser.parse_args()
    return opt
# cv2.drawContours(im, contours, -1, (0,255,0), 3)
# cv2.imshow("title", im)
# cv2.waitKey()


def main(opt):
    run(**vars(opt))


if __name__ == "__main__":
    opt = parse_opt()
    main(opt)