#!/usr/bin/python
import numpy as np
import sys

def load_mat(filematname):
  f = open ( filematname , 'r')
  m = [ map(float,line.split(',')) for line in f ]
  return m

def main(argv):
  m1 = np.matrix(load_mat(argv[0]))
  m2 = np.matrix(load_mat(argv[1]))
  diff = m1-m2
  avg = np.mean(diff)
  std = np.std(diff)
  n = m1.shape[0]*m1.shape[1]
  t = avg/np.sqrt(std**2/n)
  print t

if __name__ == "__main__":
   main(sys.argv[1:])

