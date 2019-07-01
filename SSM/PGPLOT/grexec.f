C*GREXEC -- PGPLOT device handler dispatch routine
C+
      SUBROUTINE GREXEC(IDEV,IFUNC,RBUF,NBUF,CHR,LCHR)
      INTEGER IDEV, IFUNC, NBUF, LCHR
      REAL    RBUF(*)
      CHARACTER*(*) CHR
C---
      INTEGER NDEV
      PARAMETER (NDEV=2)
      CHARACTER*10 MSG
C---
      GOTO(1,2) IDEV
      IF (IDEV.EQ.0) THEN
          RBUF(1) = NDEV
          NBUF = 1
      ELSE
          WRITE (MSG,'(I10)') IDEV
          CALL GRWARN('Unknown device code in GREXEC: '//MSG)
      END IF
      RETURN
C---
1     CALL GIDRIV(IFUNC,RBUF,NBUF,CHR,LCHR,1)
      RETURN
2     CALL NUDRIV(IFUNC,RBUF,NBUF,CHR,LCHR)
      RETURN
C
      END
