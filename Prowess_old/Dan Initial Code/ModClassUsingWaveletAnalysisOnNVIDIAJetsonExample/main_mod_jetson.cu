//
// File: main_mod_jetson.cu
//
// This file is intended to support wavelet deep learning examples.
// It may change or be removed in a future release.


// Include Files
#include "main_mod_jetson.h"
#include "modelPredictModType.h"
#include "modelPredictModType_terminate.h"
#include "rt_nonfinite.h"
#include <stdio.h>
#include <stdlib.h>

// Function Declarations
static void argInit_1024x2_real32_T(real32_T result[2048]);
static real_T argInit_real32_T();
static void main_modelPredictModType();

// Function Definitions

//
// Arguments    : real32_T result[2048]
// Return Type  : void
//

/* Read data from a file*/
int readData_real32_T(const char * const file_in, real32_T data[2048])
{
  FILE* fp1 = fopen(file_in, "r");
  if (fp1 == 0)
  {
    printf("ERROR: Unable to read data from %s\n", file_in);
    exit(0);
  }
  for(int i=0; i<2048; i++)
  {
      fscanf(fp1, "%f", &data[i]);
  }
  fclose(fp1);
  return 0;
}


/* Write data to a file*/
int writeData_real32_T(const char * const file_out, real32_T data[8])
{
  FILE* fp1 = fopen(file_out, "w");
  if (fp1 == 0) 
  {
    printf("ERROR: Unable to write data to %s\n", file_out);
    exit(0);
  }
  for(int i=0; i<8; i++)
  {
    fprintf(fp1, "%f\n", data[i]);
  }
  fclose(fp1);
  return 0;
}


static void main_modelPredictModType(const char * const file_in, const char * const file_out)
{
  real32_T predClassProb[8];
  real32_T b[2048];
          
  readData_real32_T(file_in, b);
       
  modelPredictModType(b, predClassProb);

  writeData_real32_T(file_out, predClassProb);

}

//
// Arguments    : int32_T argc
//                const char * const argv[]
// Return Type  : int32_T
//
int32_T main(int32_T argc, const char * const argv[])
{
  const char * const file_out = "predClassProb.txt";
  

  // The initialize function is being called automatically
  // from your entry-point function.
  // So, a call to initialize is not included here.
  // Invoke the entry-point functions.
  // You can call entry-point functions multiple times.
  main_modelPredictModType(argv[1], file_out);

  // Terminate the application.
  // You do not need to do this more than one time.
  modelPredictModType_terminate();
  return 0;
}

//
// File trailer for main_mod_jetson.cu
//
// [EOF]
//
