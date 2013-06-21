//
//  CurveFit.cpp
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/4/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#include "CurveFit.h"
#include <math.h>
#include <iostream>
using namespace std;

CurveFit::CurveFit(){
    /*
    
    
    double* xs = new double[5];
    xs[0] = 1;
    xs[1] = 2;
    xs[2] = 3;
    xs[3] = 4;
    xs[4] = 5;
    
    double* ys = new double[5];
    ys[0] = 1;
    ys[1] = 8;
    ys[2] = 27;
    ys[3] = 64;
    ys[4] = 125;
    
    this->xvalues = xs;
    this->yvalues = ys;
    this->numberofpoints = 5;
    
    fitCurve(3); */
}

CurveFit::CurveFit(int numpoints){
    this->numberofpoints = numpoints;
    xvalues = new double[numpoints];
    yvalues = new double[numpoints];
}

CurveFit::CurveFit(double* xs, double* ys, int numpoints){
    this->xvalues = xs;
    this->yvalues = ys;
    this->numberofpoints = numpoints;
}

double* CurveFit::getxvalues(){
    return this->xvalues;
}

double* CurveFit::getyvalues(){
    return this->yvalues;
}

double* CurveFit::getcoefficients(){
    return this->coefficients;
}

int CurveFit::getnumberofpoints(){
    return this->numberofpoints;
}

void CurveFit::setxvalues(double *xs){
    this->xvalues = xs;
}

void CurveFit::setyvalues(double *ys){
    this->yvalues = ys;
}

void CurveFit::setnumberofpoints(int numpoints){
    this->numberofpoints = numpoints;
}

void CurveFit::fitCurve(int order){
    this->coefficients = new double[(order+1)];
    
    double* polyMatrix = new double[(order+1)*numberofpoints];
    
    for (int j=0; j<numberofpoints; j++) {
        for (int i=0; i<=order; i++) {
            polyMatrix[i+((order+1)*j)] = pow(this->xvalues[j], i);
        }
    }

    double* transmatrix = new double[(order+1)*numberofpoints];
    vDSP_mtransD(polyMatrix, 1, transmatrix, 1, (order+1), numberofpoints);
    
    double dxside[(order+1)*(order+1)];
    double dyside[(order+1)*1];
    
    vDSP_mmulD(transmatrix, 1, polyMatrix, 1, dxside, 1, (order+1),  (order+1), numberofpoints);

    vDSP_mmulD(transmatrix, 1, this->yvalues, 1, dyside, 1, (order+1),  1, numberofpoints);
    
    long size = order+1;
    long pivot[size];
    long info = 0;
    long side2 = 1;
    
    dgesv_(&size, &side2, dxside, &size, pivot, dyside, &size, &info);
    
    cout << "FINAL COEFFICIENTS" << endl;
    for (int i=0; i<=order; i++) {
        cout << i << ": " << dyside[i] << endl;
        coefficients[i] = dyside[i];
    }
    
    delete transmatrix;
    delete polyMatrix;
}