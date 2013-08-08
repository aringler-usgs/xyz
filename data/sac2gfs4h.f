c
c-----------------------------------------------------------
c
      subroutine sac2gfs4h(sacname,io_gfs,npts,nlocx,chanx)
c
c Converts SAC files to GFS type 10 format. This routine is 
c typically used to process SAC files which were generated by 
c "collect". 
c 
c input:
c  sacname = name of SAC file to read
c  io_gfs  = GFS unit number to write to
c  npts    = number of samples in sac file
c
      character sacname*(*),ktemp*8,
     &          nsta*4, nchn*4, nnet*4,nlocx*2,chanx*4,nloc*4
      real*4 spare,head(100) 
      common/myhed/nscan,nnet,nsta,nloc,nchn,iy,id,ih,im,ss,
     &dt,spare(89)
      real*8 ipoch8,tt
      logical flag
      equivalence (head,nscan)
      pointer (ptr,rdata)
c
      ilen = lnblnk(sacname)
      if (ilen.eq.0) goto 100
      maxpts = npts
      ptr    = malloc(4*npts)
      if (ptr.eq.0) then
        write(*,*) 'ERROR - cannot malloc in sac2gfs4h'
        print*, ptr,npts,maxpts
        return
      endif
c
c read SAC binary file
c
      call rsac1(sacname(1:ilen),rdata,nscan,beg,dt,maxpts,nerr)
      if (nerr.ne.0) then
        write(*,*) 'ERROR reading SAC file: ',sacname(1:ilen)
        call free(ptr)
        return
      endif

      if (nscan.ne.npts) then
        write(*,*) 'WARNING - discrepancy between npts and nscan'
      endif
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
      tt = ipoch8(iy,id,ih,im,ss+beg)
      call bipoch8(tt,iy,id,ih,im,ss)
      call getkhv('KSTNM',ktemp,nerr)
      nsta = ktemp(1:4)
      call getkhv('KCMPNM',ktemp,nerr)
c     nchn = ktemp(1:4)
      nchn = chanx
      call getkhv('KNETWK',ktemp,nerr)
      nnet = ktemp(1:4)
      nloc = nlocx
      if(nloc(1:2).eq.'__') nloc(1:2) = '  '
      qlat = 0.0
      qlon = 0.0
      qdep = 0.0
      jy = 0
      jd = 0
      jh = 0
      jm = 0
      sss = 0.0
c
c write out GFS file
c
      
      call gfs_rwentry(io_gfs,head,rdata,0,'w')
      call free(ptr)
 100  continue
      return
      end

