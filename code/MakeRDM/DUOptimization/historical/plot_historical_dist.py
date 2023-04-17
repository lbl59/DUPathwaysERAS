import numpy as np
import matplotlib.pyplot as plt

#e = np.loadtxt('fallsLakeEvap.csv', delimiter=',')
e = np.loadtxt('updatedEvap.csv', delimiter=',')
#e = np.loadtxt('lakeWheelerBensonEvap.csv', delimiter=',')
d = e[:, 19:22].ravel()

plt.hist(d)
plt.show()
