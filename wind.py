import numpy as np
import matplotlib as mpl
import scipy
data=np.genfromtxt('200412.wind.stats',names=True)
#data=np.genfromtxt('200412.wind.stats', skip_header=1, names=('yr', 'mon', 'day', 'hhmm' ,  'spd',  'vspd',   'dir', 'gust
print(data.shape)
print(data['hhmm'])

class Wind_Analysis:
    def __init__(self,filename):
        data=np.genfromtxt('200412.wind.stats',names=True)

    def min(self,pts):
        x=pts.nanmin()
        inds=pts.argmin()
        return x,inds
    def max(self,pts):
        x=pts.nanmax()
        inds=pts.argmin()
        return x,inds
    def mean(self,pts):
        x=np.mean()
        return x
class Plot
    # this is where we plot some awesome stuff