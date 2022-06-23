from sklearn.linear_model import LinearRegression
import pandas as pd
from sklearn.model_selection import train_test_split
import pickle
df = pd.read_csv('magic-data.csv')
df.shape
df.plot.scatter(x='area', y='target', title='Scatterplot of hours and scores percentages');
# print(df.corr())
# print(df.describe())
y = df['target'].values.reshape(-1, 1)
X = df['area'].values.reshape(-1, 1)
# print(df['area'].values) # [2.5 5.1 3.2 8.5 3.5 1.5 9.2 ... ]
# print(df['area'].values.shape) # (25,)
# print(X.shape) # (25, 1)
# print(X)  
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2)
SEED = 42
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.2, random_state = SEED)
# print(X_train) # [[2.7] [3.3] [5.1] [3.8] ... ]
# print(y_train) # [[25] [42] [47] [35] ... ]
regressor = LinearRegression()
regressor.fit(X_train, y_train)

def calc(slope, intercept, hours):
    return slope*hours+intercept
score = calc(regressor.coef_, regressor.intercept_, 18300.5)
print(score) 
filename = 'weigh_model.sav'
pickle.dump(regressor, open(filename, 'wb'))