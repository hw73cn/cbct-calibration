#!/usr/bin/python
#	This file is part of cbct-calibration, an accurate geometric calibration of cone-beam CT.
#
#	https://github.com/Rholais/cbct-calibration
#
#	Copyright 2016 Haocheng Li and contributors
#
#	License:  Standard 3-clause BSD; see "LICENSE" for full license terms
#		and contributor agreement.

"""
	Implements accurate geometric calibration of cone-beam CT.
	利用特征数组与标签数组进行核岭回归
"""

#	This is the h5py package, a Python interface to the HDF5
#	scientific data format.
import h5py

#	This module provides a large set of colormaps, functions for
#	registering new colormaps and for getting a colormap by name,
#	and a mixin class for adding color mapping functionality.
from matplotlib import cm

#	Provides a MATLAB-like plotting framework.
#	:mod:`~matplotlib.pylab` combines pyplot with numpy into a single namespace.
#	This is convenient for interactive work, but for programming it
#	is recommended that the namespaces be kept separate, e.g.::
#		import numpy as np
#		import matplotlib.pyplot as plt
#		x = np.arange(0, 5, 0.1);
#		y = np.sin(x)
#		plt.plot(x, y)
from matplotlib import pyplot

#	Module containing Axes3D, an object which can plot 3D objects on a
#	2D matplotlib figure.
from mpl_toolkits.mplot3d import axes3d

#	Provides
#		An array object of arbitrary homogeneous items
#		Fast mathematical operations over arrays
#		Linear Algebra, Fourier Transforms, Random Number Generation
import numpy

#	Split arrays or matrices into random train and test subsets
from sklearn.cross_validation import train_test_split

from sklearn.kernel_ridge import KernelRidge
from sklearn.metrics import cohen_kappa_score, r2_score
#	from sklearn.svm import SVR
#	from sklearn.ensemble import ExtraTreesRegressor

with h5py.File('data.h5', 'r') as data:
	XX = numpy.array(data['ftr'])
	Y = numpy.array(data['ang'])

vldt = numpy.zeros((6, 6, 3))
prdc = numpy.zeros((6, 6, 2, 3))

for i in range(6):
	for j in range(6):
		print(str(i) + ', ' + str(j))
		X = XX[i, j, :, 0:2 * (2 * i + 8) * (j + 3)]

		X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size = 1/21)
		clf = KernelRidge(alpha=1.0)
		#	clf = SVR(C=1.0, epsilon=0.2)
		#	clf = ExtraTreesRegressor()
		clf = clf.fit(X_train, Y_train)

		vldtLabels = clf.predict(X_train)
		vldt[i, j] = r2_score(Y_train, vldtLabels, sample_weight=None, multioutput="raw_values")
		print(vldt[i, j])

		moreLabels = clf.predict(X_test)
		prdc[i, j, 0] = r2_score(Y_test, moreLabels, sample_weight=None, multioutput="raw_values")
		print(prdc[i, j, 0])

		X_dgtl = numpy.floor(numpy.multiply(10, X_test) + numpy.random.normal(0, 1, X_test.shape) + 0.5) / 10
		prdcLabels = clf.predict(X_dgtl)
		prdc[i, j, 1] = r2_score(Y_test, prdcLabels, sample_weight=None, multioutput="raw_values")
		print(prdc[i, j, 1])

		del clf
	

with h5py.File('score.h5', 'w') as score:
	score.create_dataset('vldt', data = vldt)
	score.create_dataset('prdc', data = prdc)

M = numpy.empty((6, 6))
N = numpy.empty((6, 6))
Z= 1 - prdc
#	lbl = ['$R_I$', '$R_D$', '$\\theta$', '$\\phi$', '$\\eta$']
ang = ['$\\theta$', '$\\phi$', '$\\eta$']
ttl = ['Noiseless $e^2$', 'Noisy $e^2$']

for i in range(6):
	M[:, i] = numpy.ones((6)) * i + 3
	N[i, :] = numpy.ones((6)) * i * 2 + 8

for i in range(2):
	for j in range(3):
		fig = pyplot.figure()
		ax = fig.gca(projection='3d')
		zmax = 2 * numpy.mean(Z[:, :, i, j])

		cset = ax.contourf(N, M, Z[:, :, i, j], zdir='z', offset=0, cmap=cm.coolwarm)
		cset = ax.contourf(N, M, Z[:, :, i, j], zdir='x', offset=6, cmap=cm.coolwarm)
		cset = ax.contourf(N, M, Z[:, :, i, j], zdir='y', offset=9, cmap=cm.coolwarm)
		ax.plot_surface(N, M, Z[:, :, i, j], cstride=1, rstride=1, alpha=0.3)

		ax.set_xlabel('Number of BBs')
		ax.set_xlim(6, 20)
		ax.set_ylabel('Number of Aspects')
		ax.set_ylim(2, 9)
		ax.set_zlabel('$e^2$ of ' + ang[j], labelpad=15)
		ax.set_zlim(0, zmax)
		ax.set_title(ttl[i])

		pyplot.show()
		
		del ax
		del fig
