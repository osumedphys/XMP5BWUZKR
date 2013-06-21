//
//  CurveFit.h
//  XMP5BWUZKR
//
//  Created by Medical Physics Lab on 6/4/13.
//  Copyright (c) 2013 Oklahoma State University Medical Physics Lab. All rights reserved.
//

#ifndef XMP5BWUZKR_CurveFit_h
#define XMP5BWUZKR_CurveFit_h

#include <Accelerate/Accelerate.h>

class CurveFit {
private:
    double* xvalues;
    double* yvalues;
    double* coefficients;
    int numberofpoints;
    
public:
    CurveFit();
    CurveFit(int numpoints);
    CurveFit(double* xs, double* ys, int numpoints);
        
    double* getxvalues();
    double* getyvalues();
    double* getcoefficients();
    int getnumberofpoints();
    
    void setxvalues(double* xs);
    void setyvalues(double* ys);
    void setnumberofpoints(int numpoints);
    
    void fitCurve(int order);

};

#endif
