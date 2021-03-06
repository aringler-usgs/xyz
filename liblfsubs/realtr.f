      SUBROUTINE REALTR(A,B,N,ISN)
C  IF ISN=1, THIS SUBROUTINE COMPLETES THE FOURIER TRANSFORM OF 2*N REAL 
C  DATA VALUES, WHERE THE ORIGINAL DATA VALUES ARE STORED ALTERNATELY IN 
C  ARRAYS A AND B, AND ARE FIRST TRANSFORMED BY A COMPLEX FOURIER TRANSFORM 
c  OF DIMENSION N. THE COSINE COEFFICIENTS ARE IN A(1),A(2),...A(N+1) AND
C  THE SINE COEFFICIENTS ARE IN B(1),B(2),...B(N+1). A TYPICAL CALLING 
C  SEQUENCE IS
C              CALL FFT (A,B,N,1)
C              CALL REALTR (A,B,N,1)
C  THE RESULTS SHOULD BE MULTIPLIED BY 0.5/N TO GIVE THE USUAL SCALING 
C  IF ISN=1, THE INVERSE TRANSFORMATION IS DONE, THE FIRST STEP IN EVALUATING 
C  A REAL FOURIER SERIES. A TYPICAL CALLING SEQUENCE IS
C              CALL REALTR (A,B,N,-1)
C              CALL FFT (A,B,N,-1)
C  THE RESULTS SHOULD BE MULTIPLIED BY 0.5 TO GIVE THE USUAL SCALING, AND 
C  THE TIME DOMAIN RESULTS ALTERNATE IN ARRAYS A AND B, I.E. A(1),B(1), A(2),B(2),
C  ...A(N),B(N). THE DATA MAY ALTERNATIVELY BE STORED IN A SINGLE COMPLEX 
C  ARRAY A, THEN THE MAGNITUDE OF ISN CHANGED TO TWO TO GIVE THE CORRECT 
C  INDEXING INCREMENT AND A(2) USED TO PASS THE INITIAL ADDRESS FOR THE 
C  SEQUENCE OF IMAGINARY VALUES,E.G.
C              CALL FFT(A,A(2),N,2)
C              CALL REALTR(A,A(2),N,2)
C  IN THIS CASE, THE COSINE AND SINE COEFFICIENTS ALTERNATE IN A.
      DIMENSION A(1),B(1)
      IF(N .LE. 1) RETURN
      INC=ISN
      IF(INC.LT.0) INC=-INC
      NK = N * INC + 2
      NH = NK / 2
      SD = 3.1415926535898E0/(2.E0*N)
      CD = 2.E0 * SIN(SD)**2
      SD = SIN(SD+SD)
      SN = 0.E0
      IF(ISN .GT. 0) GO TO 10
      CN = -1.E0
      SD = -SD
      GO TO 20
 10   CN = 1.E0
      A(NK-1) = A(1)
      B(NK-1) = B(1)
 20   DO 30 J=1,NH,INC
      K = NK - J
      AA = A(J) + A(K)
      AB = A(J) - A(K)
      BA = B(J) + B(K)
      BB = B(J) - B(K)
      XX = CN * BA + SN * AB
      YY = SN * BA - CN * AB
      B(K) = YY - BB
      B(J) = YY + BB
      A(K) = AA - XX
      A(J) = AA + XX
      AA = CN - (CD * CN + SD * SN)
      SN = (SD * CN - CD * SN) + SN
 30   CN = AA
      RETURN
      END
