c
c-----------------------------------------------------------
c
      subroutine sacq2gfs
c
c Converts SAC files to GFS type 1 format.
c Prompts user for GFS output file name and SAC input file names.
c Will keep prompting for input names until a blank is entered.
c
c same as sac2gfs2, except this one is designed to deal with 
c SAC files generated by a Quanterra (the channel name is stuffed
c in a silly place).
c
      parameter (maxpts=864000)
      character sacname*80,gname*80,ktemp*8,ktemp16*16,
     &          nsta*4, nchn*4, ntyp*4
      dimension rdata(maxpts),head(30)
      common/myhed/nscan,nsta,nchn,ntyp,iy,id,ih,im,ss,dt,
     &             qlat,qlon,qdep,jy,jd,jh,jm,sss,spare(12)
      logical flag
      real*8 tt
      equivalence (head,nscan)
c
      itype = 1
      call gfs_opena(1,'GFS output filename: ',itype,iret)
c
      do 4 j=1,80
 4      sacname(j:j) = ' '
 5    sacname = gname('input SAC file (<ret> to quit): ')
      ilen = lnblnk(sacname)
      if (ilen.eq.0) goto 100
c
c read SAC binary file
c
      call rsac1(sacname,rdata,nscan,beg,dt,maxpts,nerr)
      if (nerr.ne.0) pause 'error reading SAC file'
      call getlhv('LEVEN',flag,nerr)
      call getnhv('NZYEAR',iy,nerr)
      call getnhv('NZJDAY',id,nerr)
      call getnhv('NZHOUR',ih,nerr)
      call getnhv('NZMIN', im,nerr)
      call getnhv('NZSEC', isec,nerr)
      call getnhv('NZMSEC',msec,nerr)
      ss = float(isec) + float(msec) / 1000.
c
c The start of the data is "beg" seconds after the
c time "iy,id:ih:im:ss".
c So, we convert time to epochal then back again
c to put the actual start time into "iy,id:ih:im:ss".
c
      call dat2ep(iy,id,ih,im,ss+beg,tt)
      call ep2dat(tt,iy,id,ih,im,ss)
c
      call getkhv('KSTNM',ktemp,nerr)
      ic = 0
      nsta = '    '
      do 10 i=1,8
        if (ktemp(i:i).ne.' ') then
          ic = ic + 1
          if (ic.gt.4) goto 10
          nsta(ic:ic) = ktemp(i:i)
        endif
 10   continue
c
c A SAC file from a Quanterra has the channel name
c in the KEVNM string!
c
      call getkhv('KEVNM',ktemp16,nerr)
      ilen = lnblnk(ktemp16)
      if (ktemp16(ilen-2:ilen).eq.'VBB') then
        nchn(1:2) = 'BH'
        nchn(3:3) = ktemp16(ilen-3:ilen-3)
      elseif (ktemp16(ilen-2:ilen).eq.'VLP') then
        nchn(1:2) = 'VH'
        nchn(3:3) = ktemp16(ilen-3:ilen-3)
      elseif (ktemp16(ilen-2:ilen).eq.'ULP') then
        nchn(1:2) = 'UH'
        nchn(3:3) = ktemp16(ilen-3:ilen-3)
      elseif (ktemp16(ilen-1:ilen).eq.'LP') then
        nchn(1:2) = 'LH'
        nchn(3:3) = ktemp16(ilen-2:ilen-2)
      elseif (ktemp16(ilen-2:ilen).eq.'SSP') then
        nchn(1:2) = 'SH'
        nchn(3:3) = ktemp16(ilen-3:ilen-3)
      endif
      nchn(4:4) = ' '
      write(*,'(a,$)') 'enter two digit network code: '
      read(*,*) ntyp
      call upcase(ntyp)
      ntyp(3:4) = '  '
      call rmblnk(nsta)
      call rmblnk(nchn)
      call rmblnk(ntyp)
c
c write out GFS file
c
      iret = iret + 1
      call prhdr(iret,head,itype)
      call gfs_rwentry(1,head,rdata,0,'w')
      goto 5
c
 100  call gfs_close(1)
      return
      end
