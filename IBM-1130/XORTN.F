// JOB
// FOR
*IOCS (TYPEWRITER)
*LIST SOURCE PROGRAM
C
C -------------------------
C XOR MULTILAYER PERCEPTRON
C DAMIEN BOUREILLE, 2025
C MIT LICENSE
C -------------------------
C
C VARS
      INTEGER EPCHS, SMPLS, I, J, EPOCH, SMPL, M
      INTEGER ITMP1, ITMP2
      REAL LOSS, ERR, RTMP1, RTMP2, R
C DIMENSIONS     
      REAL XIN(4,2), TRGT(4,1), W1(2,4), W2(4,1), DW1(2,4)
     $ , DW2(4,1), Z1(4), A1(4), B1(4), DB1(4), DELT1(4)
     $ , B2(1), DB2(1), Z2(1), A2(1), DELT2(1)
C COMMON
      COMMON XIN, TRGT, W1, W2, DW1, DW2, Z1
     $, A1, B1, DB1, DELT1, B2, DB2, Z2, A2, DELT2, R
C
C CONST
C     LEARNING RATE
      R = 0.5
C     BATCH SIZE      
      SMPLS = 4
C
      ERR = 0.
      EPCHS = 500
C FMT
 9000 FORMAT('EPOCH',I4, ' LOSS ', F14.12, ' LR ', F8.6)
 9001 FORMAT(' ')
 9002 FORMAT(2I2, 1X, 'GOT:', F8.6, ' EXPECTED:', F2.0)
C
      CALL INIT
C
C *** TRAINING LOOP ***
C
      DO 100 EPOCH = 1, EPCHS
          LOSS = 0.0
C RESET GRADIENT          
          CALL ZEROG
C
C SAMPLES PER EPOCH (BATCH GRADIENT DESCENT)
          DO 200 SMPL = 1, SMPLS          
              CALL FORWD(SMPL)
              ERR = TRGT(SMPL,1) - A2(1)
              LOSS = LOSS + ERR * ERR
C
C BACKPROPAGATION
              DELT2(1) = ERR * SIGMD(Z2(1))
              DO 300 I = 1, 4
                  DW2(I,1) = DW2(I,1) + A1(I) * DELT2(1)
 300          CONTINUE
              DB2(1) = DB2(1) + DELT2(1)
C
C AVERAGE HIDDEN LAYER GRADIENTS + UPDATE WEIGHTS
              DO 400 I = 1, 4
                  DELT1(I) = DELT2(1) * W2(I,1) * RELUD(Z1(I))
                  DO 500 J = 1, 2
                      DW1(J,I) = DW1(J,I) + (XIN(SMPL,J) * DELT1(I))
 500              CONTINUE
                  DB1(I) = DB1(I) + DELT1(I)
 400          CONTINUE
 200      CONTINUE
C 
C AVERAGE OUTPUT LAYER GRADIENTS + UPDATE WEIGHTS
          DO 610 I = 1, 2
            DO 620 J = 1, 4
                DW1(I,J) = DW1(I,J) / 4.0
 620        CONTINUE
          CALL UPDAT
 610      CONTINUE
          DO 630 I = 1, 4
              DW2(I,1) = DW2(I,1) / 4.0
              DB1(I) = DB1(I) / 4.0
 630      CONTINUE
          DB2(1) = DB2(1) / 4.0
 203      CALL UPDAT
C
C MEAN SQUARE ERROR
          LOSS = LOSS / FLOAT(SMPLS)
C          
C TRAINING STATUS
          IF (EPOCH - 1.0) 204, 205, 204
 204      M = IMOD(EPOCH, 100)
          IF (M - 0) 206, 205, 206
 205      CONTINUE
          R = R * 0.85
          WRITE(1,9000) EPOCH, LOSS, R
 206      CONTINUE
 100  CONTINUE
C 
C TRAINING DONE
      WRITE(1, 9001)
      DO 600 SMPL = 1, SMPLS
        CALL FORWD(SMPL)
        ITMP1 = NINT(XIN(SMPL,1))
        ITMP2 = NINT(XIN(SMPL,2))
        RTMP1 = A2(1)
        RTMP2 = TRGT(SMPL,1)
        WRITE(1, 9002) ITMP1, ITMP2, RTMP1, RTMP2
 600  CONTINUE
      STOP
      END
// DUP
*DELETE     WS  UA  XORTN
*STORE      WS  UA  XORTN
C
// FOR
*LIST SOURCE PROGRAM
C
C *** INIT NETWORK DATA ***
C
      SUBROUTINE INIT
      REAL HSCL1, HSCL2, RND
      INTEGER I, J, ISEED
      COMMON XIN(4,2), TRGT(4,1), W1(2,4), W2(4,1), DW1(2,4), DW2(4,1)
     $ , Z1(4), A1(4), B1(4), DB1(4), DELT1(4)
     $ , B2(1), DB2(1), Z2(1), A2(1), DELT2(1), R
C DEBUG
 9000 FORMAT ('W1(', I1, ',',I1,')', F16.12)
 9001 FORMAT ('W2(', I1, ')  ', F16.12)
 9002 FORMAT ('SEED' I8) 
C INIT INPUT AND OUTPUT NEURONS
      XIN(1,1) = 0.
      XIN(1,2) = 0.
      XIN(2,1) = 0.
      XIN(2,2) = 1.
      XIN(3,1) = 1.
      XIN(3,2) = 0.
      XIN(4,1) = 1.
      XIN(4,2) = 1.
      TRGT(1,1) = 0.
      TRGT(2,1) = 1.
      TRGT(3,1) = 1.
      TRGT(4,1) = 0.
C INIT WEIGHTS + BIASES
      HSCL1 = SQRT(2.0 / FLOAT(2 + 4)) * 0.5
      HSCL2 = SQRT(2.0 / FLOAT(4 + 1)) * 0.5
C
      ISEED = 887
      DO 10 I = 1, 2
          DO 20 J = 1, 4
C             COULD BE CALLED AN RNG...
              RND = FLOAT(IMOD(ISEED*7+1, 32767)) / 32767.
              W1(I,J) = (RND - 0.25) * 2.0 * HSCL1
              ISEED = ISEED + 3277
 20       CONTINUE
 10   CONTINUE
      DO 30 I = 1, 4
           B1(I) = 0
 30   CONTINUE
C
      ISEED = 883
      DO 40 I = 1, 4
           RND = FLOAT(IMOD(ISEED*7+1, 32767)) / 32767.
           W2(I,1) = (RND - 0.25) * 2.0 * HSCL2
           ISEED = ISEED + 3277
 40   CONTINUE
      B2(1) = 0
      RETURN
      END
C
// DUP
*DELETE     WS  UA  INIT
*STORE      WS  UA  INIT
C
// FOR
*LIST SOURCE PROGRAM
C
C *** FORWARD PASS ***
C
      SUBROUTINE FORWD(S)
      INTEGER I, J, S
      REAL TEMP
      COMMON XIN(4,2), TRGT(4,1), W1(2,4), W2(4,1), DW1(2,4), DW2(4,1)
     $ , Z1(4), A1(4), B1(4), DB1(4), DELT1(4)
     $ , B2(1), DB2(1), Z2(1), A2(1), DELT2(1), R
C     LAYER 1
 9000 FORMAT('FWD: I=', I2, ' J=', I2, ' S=', I2 )
 9001 FORMAT('FWD: XIN(S,J)=', F20.12, ' W1(J,I)=', F20.12)
 9002 FORMAT('FWD: TEMP=', F20.12, ' Z1(I)=', F20.12)
C INPUT -> HIDDEN ACTIVATIONS
      DO 1000 I = 1, 4
          Z1(I) = 0.0
          DO 2000 J = 1, 2
              TEMP = XIN(S,J) * W1(J,I)
              Z1(I) = Z1(I) + TEMP
 2000     CONTINUE
C      BIAS
          Z1(I) = Z1(I) + B1(I)

C      RELU ACTIVATION
          A1(I) = RELU(Z1(I))
C         A1(I) = TANH(Z1(I))

 1000 CONTINUE
C
C HIDDEN -> OUTPUT ACTIVATIONS
      Z2(1) = 0.0
      DO 3000 J = 1, 4
          Z2(1) = Z2(1) + A1(J) * W2(J,1)
 3000 CONTINUE
C     BIAS
      Z2(1) = Z2(1) + B2(1)
C     ACTIVATION
      A2(1) = TANH(Z2(1))
      RETURN
      END
C
// DUP
*DELETE     WS  UA  FORWD
*STORE      WS  UA  FORWD
// FOR
*LIST SOURCE PROGRAM
C
C *** UPDATE GRADIENTS ***
C
      SUBROUTINE UPDAT
      INTEGER I, J
      COMMON XIN(4,2), TRGT(4,1), W1(2,4), W2(4,1), DW1(2,4), DW2(4,1)
     $ , Z1(4), A1(4), B1(4), DB1(4), DELT1(4)
     $ , B2(1), DB2(1), Z2(1), A2(1), DELT2(1), R
      DO 10 I = 1, 4
          W2(I,1) = W2(I,1) + R * DW2(I,1)
 10   CONTINUE
      B2(1) = B2(1) + R * DB2(1)
      DO 20 I = 1, 2
          DO 30 J = 1, 4
              W1(I,J) = W1(I,J) + R * DW1(J,I)
 30       CONTINUE
 20   CONTINUE
      DO 40 I = 1, 4
          B1(I) = B1(I) + R * DB1(I)
 40   CONTINUE
      RETURN
      END
C
// DUP
*DELETE     WS  UA  UPDAT
*STORE      WS  UA  UPDAT
// FOR
*LIST SOURCE PROGRAM
C
C *** RESET GRADIENTS ***
C
      SUBROUTINE ZEROG
      INTEGER I, J
      COMMON XIN(4,2), TRGT(4,1), W1(2,4), W2(4,1), DW1(2,4), DW2(4,1)
     $ , Z1(4), A1(4), B1(4), DB1(4), DELT1(4)
     $ , B2(1), DB2(1), Z2(1), A2(1), DELT2(1), R
      DO 10 I = 1, 2
          DO 20 J = 1, 4
              DW1(I,J) = 0.0
 20       CONTINUE
 10   CONTINUE
      DO 40 I = 1, 4
          DW2(I,1) = 0.0
          DB1(I) = 0.0
 40   CONTINUE
      DB2(1) = 0.0
      RETURN
      END
// DUP
*DELETE     WS  UA  ZEROG
*STORE      WS  UA  ZEROG
*STORECI    WS  UA  XOR
C
// XEQ XORTN