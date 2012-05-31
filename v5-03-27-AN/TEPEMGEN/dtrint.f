      FUNCTION DTRINT(F,NSD,NPT,EPS,X1,Y1,X2,Y2,X3,Y3)
C     INTEGRATION OVER A TRIANGLE USING A 7-, 25- OR 64-POINT FORMULA,
C     WITH OR WITHOUT SUBDIVISION OF THE TRIANGLE.
C     CERNLIB program D105.

      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      CHARACTER NAME*(*)
      CHARACTER*80 ERRTXT
      PARAMETER (NAME = 'DTRINT')
      PARAMETER (Z1 = 1, HALF = Z1/2, KMX = 35)

      DIMENSION R(KMX),XP1(KMX),XP2(KMX),XP3(KMX),YP1(KMX),YP2(KMX)
      DIMENSION YP3(KMX)
      DIMENSION U(8,3),V(32,3),W(32,3),UU(5,2),WW(5,2)
      DIMENSION G1(32),G2(32)
      DIMENSION JZ(3),JZ0(3),JZ1(3),IZ(3,3)

      DATA JZ /2,5,8/, JZ0 /2,10,32/, JZ1 /3,5,0/
      DATA ((IZ(I,M),I=1,3),M=1,3) /1,0,1, 5,5,1, 8,24,8/

      DATA (U(J,1),J=1,2)
     1/0.89871 34926 76543 661D0, 0.52985 79358 94884 910D0/

      DATA (UU(J,1),J=1,3)
     1/0.20257 30146 46912 678D0, 0.94028 41282 10230 180D0,
     2 0.66666 66666 66666 667D0/

      DATA (V(J,1),J=1,2)
     1/0.69614 04780 29630 984D0,-0.41042 61923 15345 269D0/

      DATA (W(J,1),J=1,2)
     1/0.12593 91805 44827 153D0, 0.13239 41527 88506 181D0/

      DATA (WW(J,1),J=1,3)
     1/0.12593 91805 44827 153D0, 0.13239 41527 88506 181D0,
     2 0.22500 00000 00000 000D0/

      DATA (U(J,2),J=1,5)
     1/0.09853 50857 98826 426D0, 0.30453 57266 46363 905D0,
     2 0.56202 51897 52613 856D0, 0.80198 65821 26391 827D0,
     3 0.96019 01429 48531 258D0/

      DATA (UU(J,2),J=1,5)
     1/0.09853 50857 98826 426D0, 0.30453 57266 46363 905D0,
     2 0.56202 51897 52613 856D0, 0.80198 65821 26391 827D0,
     3 0.96019 01429 48531 258D0/

      DATA (V(J,2),J=1,10)
     1/0.08929 05088 68733 569D0, 0.27596 41378 55221 135D0,
     2 0.50929 58998 63672 021D0, 0.72674 40774 36169 444D0,
     3 0.87010 49558 08923 811D0, 0.05305 81196 71298 357D0,
     4 0.16398 31426 29800 463D0, 0.30263 33161 88105 613D0,
     5 0.43184 51615 91612 961D0, 0.51703 29238 43772 854D0/

      DATA (W(J,2),J=1,10)
     1/0.00373 11043 33755 67687D0, 0.01751 09983 64327 66347D0,
     2 0.03468 30128 62731 40026D0, 0.03960 81662 64094 70756D0,
     3 0.02293 01607 03185 09559D0, 0.00753 74033 90655 24076D0,
     4 0.03537 49042 20966 93175D0, 0.07006 50090 06743 44063D0,
     5 0.08001 45747 72320 84819D0, 0.04632 24438 58996 77269D0/

      DATA (WW(J,2),J=1,5)
     1/0.00895 88135 94562 71712D0, 0.04204 59349 74644 15024D0,
     2 0.08327 79304 30389 93562D0, 0.09510 37941 15908 01948D0,
     3 0.05505 79713 28939 62198D0/

      DATA (U(J,3),J=1,8)
     1/0.04463 39552 89969 851D0, 0.14436 62570 42145 571D0,
     2 0.28682 47571 44430 519D0, 0.45481 33151 96573 351D0,
     3 0.62806 78354 16727 698D0, 0.78569 15206 04369 242D0,
     4 0.90867 63921 00206 044D0, 0.98222 00848 52636 548D0/

      DATA (V(J,3),J=1,32)
     1/0.04286 15345 20322 596D0, 0.13863 34522 58088 400D0,
     2 0.27543 49048 78165 863D0, 0.43675 26131 83286 138D0,
     3 0.60312 71715 43047 645D0, 0.75449 15975 72500 770D0,
     4 0.87259 27221 72605 828D0, 0.94321 59843 32136 212D0,
     5 0.03555 83759 33897 592D0, 0.11501 17574 55156 297D0,
     6 0.22850 36689 09272 431D0, 0.36233 45216 98467 603D0,
     7 0.50036 05900 18245 933D0, 0.62593 40960 53638 777D0,
     8 0.72391 20204 03394 633D0, 0.78250 18150 44463 514D0,
     9 0.02345 65900 87635 536D0, 0.07586 91469 73958 963D0,
     A 0.15073 57058 45778 370D0, 0.23901 91375 97290 126D0,
     B 0.33007 00031 37485 188D0, 0.41290 63582 74039 218D0,
     C 0.47753 88941 74496 369D0, 0.51618 84882 60827 229D0,
     D 0.00818 74136 31782 437D0, 0.02648 17727 48961 059D0,
     E 0.05261 35967 85690 189D0, 0.08342 85178 75344 723D0,
     F 0.11520 93988 52684 066D0, 0.14412 30431 93925 944D0,
     G 0.16668 27291 29138 200D0, 0.18017 31901 16990 201D0/

      DATA (W(J,3),J=1,32)
     1/0.00033 35674 06495 41982D0, 0.00180 62109 19037 15084D0,
     2 0.00459 97558 03491 41419D0, 0.00801 72595 31391 49525D0,
     3 0.01073 50189 73158 61631D0, 0.01138 87974 04616 51588D0,
     4 0.00922 38453 90918 29977D0, 0.00450 98127 16079 21752D0,
     5 0.00073 27880 81649 19485D0, 0.00396 79231 50289 07586D0,
     6 0.01010 48428 76312 33624D0, 0.01761 24888 63394 88637D0,
     7 0.02358 29214 92410 93797D0, 0.02501 91560 68339 84265D0,
     8 0.02026 31427 34638 24614D0, 0.00990 72539 59652 71520D0,
     9 0.00103 37234 54873 38862D0, 0.00559 74371 44935 08001D0,
     A 0.01425 46165 12792 75399D0, 0.02484 54407 11607 46855D0,
     B 0.03326 77614 32852 32482D0, 0.03529 38169 93822 26192D0,
     C 0.02858 46432 80634 70277D0, 0.01397 58834 07425 66299D0,
     D 0.00119 51124 99230 79556D0, 0.00647 13314 41724 90169D0,
     E 0.01648 01043 12102 39366D0, 0.02872 44103 85925 30995D0,
     F 0.03846 16575 37508 13161D0, 0.04080 40290 04108 74571D0,
     G 0.03304 73922 30182 37768D0, 0.01615 78542 78398 33562D0/

      IF(NPT .EQ. 7) THEN
       M=1
      ELSE IF(NPT .EQ. 25) THEN
       M=2
      ELSE IF(NPT .EQ. 64) THEN
       M=3
      ELSE
       H=0
       WRITE(ERRTXT,101) NPT
       CALL MTLPRT(NAME,'D105.1',ERRTXT)
       GO TO 99
      END IF
      K=0
      C1=X1
      D1=Y1
      C2=X2
      D2=Y2
      C3=X3
      D3=Y3
      A11=HALF*(C2+C3)-C1
      A12=HALF*(C3-C2)
      A21=HALF*(D2+D3)-D1
      A22=HALF*(D3-D2)
      DO 1 J = 1,JZ(M)
      G1(J)=A11*U(J,M)+C1
      G2(J)=A21*U(J,M)+D1
      DO 1 I = IZ(1,M),IZ(2,M),IZ(3,M)
      G1(J+I)=G1(J)
    1 G2(J+I)=G2(J)
      S=0
      DO 2 J = 1,JZ0(M)
      H1=A12*V(J,M)
      H2=A22*V(J,M)
    2 S=S+W(J,M)*(F(G1(J)+H1,G2(J)+H2)+F(G1(J)-H1,G2(J)-H2))
      DO 3 J = 1,JZ1(M)
    3 S=S+WW(J,M)*F(A11*UU(J,M)+C1,A21*UU(J,M)+D1)
      S=HALF*ABS(C1*(D2-D3)+C2*(D3-D1)+C3*(D1-D2))*S
      H=S
      IF(NSD .EQ. 0) GO TO 99
      H=0

   10 K=K+1
      SUM0=S
      U1=C1
      V1=D1
      U2=C2
      V2=D2
      U3=C3
      V3=D3
   11 C1=HALF*(U2+U3)
      D1=HALF*(V2+V3)
      C2=U1
      D2=V1
      C3=U2
      D3=V2
      XP1(K)=C1
      YP1(K)=D1
      XP2(K)=C2
      YP2(K)=D2
      XP3(K)=U3
      YP3(K)=V3
      A11=HALF*(C2+U3)-C1
      A12=HALF*(U3-C2)
      A21=HALF*(D2+V3)-D1
      A22=HALF*(V3-D2)
      DO 4 J = 1,JZ(M)
      G1(J)=A11*U(J,M)+C1
      G2(J)=A21*U(J,M)+D1
      DO 4 I = IZ(1,M),IZ(2,M),IZ(3,M)
      G1(J+I)=G1(J)
    4 G2(J+I)=G2(J)
      S=0
      DO 5 J = 1,JZ0(M)
      H1=A12*V(J,M)
      H2=A22*V(J,M)
    5 S=S+W(J,M)*(F(G1(J)+H1,G2(J)+H2)+F(G1(J)-H1,G2(J)-H2))
      DO 6 J = 1,JZ1(M)
    6 S=S+WW(J,M)*F(A11*UU(J,M)+C1,A21*UU(J,M)+D1)
      S=HALF*ABS(C1*(D2-V3)+C2*(V3-D1)+U3*(D1-D2))*S
      R(K)=S
      A11=HALF*(C2+C3)-C1
      A12=HALF*(C3-C2)
      A21=HALF*(D2+D3)-D1
      A22=HALF*(D3-D2)
      DO 7 J = 1,JZ(M)
      G1(J)=A11*U(J,M)+C1
      G2(J)=A21*U(J,M)+D1
      DO 7 I = IZ(1,M),IZ(2,M),IZ(3,M)
      G1(J+I)=G1(J)
    7 G2(J+I)=G2(J)
      S=0
      DO 8 J = 1,JZ0(M)
      H1=A12*V(J,M)
      H2=A22*V(J,M)
    8 S=S+W(J,M)*(F(G1(J)+H1,G2(J)+H2)+F(G1(J)-H1,G2(J)-H2))
      DO 9 J = 1,JZ1(M)
    9 S=S+WW(J,M)*F(A11*UU(J,M)+C1,A21*UU(J,M)+D1)
      S=HALF*ABS(C1*(D2-D3)+C2*(D3-D1)+C3*(D1-D2))*S
      SUM=S+R(K)
      IF(ABS(SUM0-SUM) .GT. EPS*(1+ABS(SUM))) THEN
       IF(K .LT. KMX) GO TO 10
       H=0
       CALL MTLPRT(NAME,'D105.2','TOO HIGH ACCURACY REQUIRED')
       GO TO 99
      ELSE
       H=H+SUM
       K=K-1
       IF(K .LE. 0)  GO TO 99
       U1=XP1(K)
       V1=YP1(K)
       U2=XP2(K)
       V2=YP2(K)
       U3=XP3(K)
       V3=YP3(K)
       SUM0=R(K)
       GO TO 11
      END IF
   99 DTRINT=H
      RETURN
  101 FORMAT('INCORRECT NUMBER OF POINTS =',I5)
      END
