% signal Generator:

% build 3 signals, symbol rate 1, 4, & 16, 
%deliver to synthesizer running at 128

% signal 1, symbol rate 1, sample rate 2

hh=[ 0.0004242  -0.0002926  -0.0029610   0.0029667   0.0107196 ...
    -0.0146673  -0.0261556   0.0501713   0.0473794  -0.1455471 ...
    -0.0667086   0.5700707   1.0000000   0.5700707  -0.0667086 ...
    -0.1455471   0.0473794   0.0501713  -0.0261556  -0.0146673 ...
     0.0107196   0.0029667  -0.0029610  -0.0002926   0.0004242];
 hh2=reshape([hh 0],2,13);
 
 y1=zeros(6,400);
 for kk=1:6
   x1=(floor(2*rand(1,200))-0.5)/0.5+j*(floor(2*rand(1,200))-0.5)/0.5;
   reg_hh=zeros(1,13);
   mm=1;
     for nn=1:200
       reg_hh=[x1(nn) reg_hh(1:12)];
       y1(kk,mm)=reg_hh*hh2(1,:)';
       y1(kk,mm+1)=reg_hh*hh2(2,:)';
       mm=mm+2;
     end
 end
 
w1=kaiser(400,12)';
w1=10*w1/sum(w1);
 figure(1)
  subplot(2,3,1)
  plot((-0.5:1/1024:0.5-1/1024)*2,fftshift(20*log10(abs(fft(y1(1,:).*w1,1024)))))
  grid on
  axis([-1 1 -120 10])
  title('Spectrum, Signal s1(1,n)')
  subplot(2,3,2)
  plot((-0.5:1/1024:0.5-1/1024)*2,fftshift(20*log10(abs(fft(y1(2,:).*w1,1024)))))
  grid on
  axis([-1 1 -120 10])
  title('Spectrum, Signal s1(2,n)')
   subplot(2,3,3)
  plot((-0.5:1/1024:0.5-1/1024)*2,fftshift(20*log10(abs(fft(y1(3,:).*w1,1024)))))
  grid on
  axis([-1 1 -120 10])
  title('Spectrum, Signal s1(3,n)')
% signal 4, symbol rate 4, sample rate 8
x4=(floor(2*rand(1,800))-0.5)/0.5+j*(floor(2*rand(1,800))-0.5)/0.5;

 reg_hh=zeros(1,13);
 mm=1;
 y4=zeros(1,1600);
 for nn=1:800
     reg_hh=[x4(nn) reg_hh(1:12)];
     y4(mm)=reg_hh*hh2(1,:)';
     y4(mm+1)=reg_hh*hh2(2,:)';
     mm=mm+2;
 end

  % 8-point synthesizer
 % Nyquist analysis filter
g8=sinc(-7+1/8:1/8:7-1/8).*kaiser(111,10)';
scl_g8=1/8;

 
subplot(2,1,2)
w4=kaiser(1024,12)';
w4=15*w4/sum(w4);
plot((-0.5:1/1024:0.5-1/1024)*8,fftshift(20*log10(abs(fft(y4(201:1224).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*8,fftshift(20*log10(abs(fft(g8/8,1024)))),'r')

hold off
grid on
axis([-4 4 -120 10])
title('Spectrum, Input s4(n)')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')

 % 8-point synthesizer
 % Nyquist analysis filter
g8=sinc(-7+1/8:1/8:7-1/8).*kaiser(111,10)';
scl_g8=1/8;

gg8=reshape([0 g8],8,14);
 
 % Analysis Process
reg_s4=zeros(8,28);
v1_s4=zeros(1,8)';
v2_s4=zeros(1,8)';
v3_s4=zeros(1,8)';
v4_s4=zeros(8,400);

m1=1;
flg1=0;

for nn=1:4:1600-3
    v1_s4(1:4)=fliplr(y4(nn:nn+3)).';
    v1_s4(5:8)=v1_s4(1:4);
    reg_s4=[v1_s4 reg_s4(:,1:27)];
    
    for kk=1:4
        v2_s4(kk)  =reg_s4(kk,1:2:28)  *gg8(kk,:)';
        v2_s4(kk+4)=reg_s4(kk+4,2:2:28)*gg8(kk+4,:)';
    end
    
    if flg1==0
        flg1=1;
    elseif flg1==1
        flg1=0;
        v2_s4=[v2_s4(5:8);v2_s4(1:4)];
    end
    
    v3_s4=fftshift(ifft(v2_s4));
    
    v4_s4(:,m1)=v3_s4;
    m1=m1+1;
end
  
figure(2)
subplot(3,1,1)
w4=kaiser(1024,12)';
w4=15*w4/sum(w4);
plot((-0.5:1/1024:0.5-1/1024)*8,fftshift(20*log10(abs(fft(y4(201:1224).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*8,fftshift(20*log10(abs(fft(g8/8,1024)))),'r')
hold off
grid on
axis([-4 4 -120 10])
title('Spectrum, Signal s4(n)')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')


ww4=kaiser(400,12)';
ww4=15*ww4/sum(ww4);
for kk=1:8
    subplot(3,4,kk+4)
    plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(v4_s4(kk,1:400).*ww4,512)))))
    grid on
    axis([-1 1 -120 10])
end


% signal 16, symbol rate 16, sample rate 32
x16=(floor(2*rand(1,3200))-0.5)/0.5+j*(floor(2*rand(1,3200))-0.5)/0.5;

 reg_hh=zeros(1,13);
 mm=1;
 y16=zeros(1,6400);
 for nn=1:3200
     reg_hh=[x16(nn) reg_hh(1:12)];
     y16(mm)=reg_hh*hh2(1,:)';
     y16(mm+1)=reg_hh*hh2(2,:)';
     mm=mm+2;
 end

% 32-path Nyquist analysis filter
g32=sinc(-7+1/32:1/32:7-1/32).*kaiser(447,10)';
scl_g328=1/32;

gg32=reshape([0 g32],32,14);
 
 % Analysis Process
reg_s32=zeros(32,28);
v1_s32=zeros(1,32)';
v2_s32=zeros(1,32)';
v3_s32=zeros(1,32)';
v4_s32=zeros(32,400);

m1=1;
flg1=0;

for nn=1:16:6400-15
    v1_s32(1:16)=fliplr(y16(nn:nn+15)).';
    v1_s32(17:32)=v1_s32(1:16);
    reg_s32=[v1_s32 reg_s32(:,1:27)];
    
    for kk=1:16
        v2_s32(kk)   =reg_s32(kk,1:2:28)   *gg32(kk,:)';
        v2_s32(kk+16)=reg_s32(kk+16,2:2:28)*gg32(kk+16,:)';
    end
    
    if flg1==0
        flg1=1;
    elseif flg1==1
        flg1=0;
        v2_s32=[v2_s32(17:32);v2_s32(1:16)];
    end
    
    v3_s32=fftshift(ifft(v2_s32));
    
    v4_s32(:,m1)=v3_s32;
    m1=m1+1;
end

figure(3)
subplot(3,1,1)
w32=kaiser(1024,12)';
w32=15*w32/sum(w32);
plot((-0.5:1/1024:0.5-1/1024)*32,fftshift(20*log10(abs(fft(y16(201:1224).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*32,fftshift(20*log10(abs(fft(g32/32,1024)))),'r')
hold off
grid on
axis([-16 16 -120 10])
title('Spectrum, Signal s16(n)')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')

ww32=kaiser(400,12)';
ww32=20*ww32/sum(ww32);
vv=[4 5 6 7 8 9 10 24 25 26 27 28 29 30];
for kk=1:14
    subplot(3,7,kk+7)
    plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(v4_s32(vv(kk),1:400).*ww32,512)))))
    grid on
    axis([-1 1 -120 10])
end

figure(4)
for kk=1:32
    subplot(4,8,kk)
    plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(v4_s32(kk,1:400).*ww32,512)))))
    grid on
    axis([-1 1 -120 10])
end

% synthesizer for three channels s1, s4, s16 in 128 point transform

% synthesis filter
h128a=remez(1790,[0 0.73 1.27 64.0]/64.0,{'myfrf',[1 1 0 0]},[1 1.01]);
scl_h128=max(h128a);
h128=h128a/scl_h128;

hh128=reshape([0 h128],128,14);

reg_s128=zeros(128,28);
v1_s128=zeros(1,128)';
v2_s128=zeros(1,128)';
x128=zeros(1,25600);
m2=0;
flg2=0;
for nn=1:400
    v1_s128(30:36)=v4_s4(2:8,nn);
    v1_s128(50:74)=v4_s32(5:29,nn);
    v1_s128(85:4:108)=y1(:,nn);
    
    v2_s128=128*ifft(fftshift(v1_s128));
  
    if flg2==0
        flg2=1;
    elseif flg2==1
        flg2=0;
        v2_s128=[v2_s128(65:128);v2_s128(1:64)];
    end
    
    reg_s128=[v2_s128 reg_s128(:,1:27)];
    
    for kk=1:64
        p1=reg_s128(kk,1:2:28)*hh128(kk,:)';
        p2=reg_s128(kk+64,2:2:28)*hh128(kk+64,:)';
        x128(m2+kk)=(p1+p2);
    end
    m2=m2+64;
end

figure(5)
subplot(2,1,1)
plot(real(x128(1:4000)))
grid on
title('Composite Time Series')

subplot(2,1,2)
ww=kaiser(4096,12)';
ww=2*ww/sum(ww);
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(x128(2001:6096).*ww)))))
hold on
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(h128/64,4096)))),'r')
hold off
grid on
axis([-64 64 -120 10])
title('Composite Spectrum from Signal Generator')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')

    
% now analysis and synthesis with shifted spectra    

% Nyquist analysis filter
g128=sinc(-7+1/128:1/128:7-1/128).*kaiser(1791,10)';
scl_g128=1/128;

% synthesis filter Used earlier in signal generator 
% h128a=remez(1790,[0 0.73 1.27 64.0]/64.0,{'myfrf',[1 1 0 0]},[1 1.01]);
% scl_h128=max(h128a);
% h128=h128a/scl_h128;

 hh128=reshape([0 h128],128,14);
 gg128=reshape([0 g128],128,14);
%  
% figure(6)
% subplot(3,1,1)
% plot(-895.0:895.0,g128)
% grid on
% title('Prototype Low Pass Nyquist Filter Impulse response')
% axis([-900 900 -0.3 1.2])
% 
% subplot(3,1,2)
% plot((-0.5:1/8192:0.5-1/8192)*128,fftshift(20*log10(abs(fft(g128*scl_g128,8192)))))
% hold on
% plot((-0.5:1/8192:0.5-1/8192)*128,fftshift(20*log10(abs(fft(h128*scl_h128,8192)))),'r')
% hold off
% grid on
% axis([-2 2 -110 10])
% title('Spectra: Analysis Filter and Synthesis Filter')
% xlabel('Normalized Frequency')
% ylabel('Log Mag (dB)')
% 
% subplot(3,1,3)
% plot((-0.5:1/8192:0.5-1/8192)*128,fftshift(20*log10(abs(fft(g128*scl_g128,8192)))))
% hold on
% plot((-0.5:1/8192:0.5-1/8192)*128,fftshift(20*log10(abs(fft(h128*scl_h128,8192)))),'r')
% hold off
% grid on
% axis([-2 2 -0.0002 0.0002])
% title('Spectra: Zoom To Pass Band Ripple')
% xlabel('Normalized Frequency')
% ylabel('Log Mag (dB)')

reg_a=zeros(128,28);
v1=zeros(1,128)';
v2=zeros(1,128)';
v3=zeros(1,128)';
v4=zeros(1,128)';
v5=zeros(1,128)';
reg_b=zeros(128,28);

 
y128=zeros(1,25600);

m1=1;
m2=0;
flg1=0;
flg2=0;

for nn=1:64:25600-63

    v1(1:64)=fliplr(x128(nn:nn+63)).';
    v1(65:128)=v1(1:64);
    reg_a=[v1 reg_a(:,1:27)];
    
    for kk=1:64
        v2(kk)=reg_a(kk,1:2:28)*gg128(kk,:)';
        v2(kk+64)=reg_a(kk+64,2:2:28)*gg128(kk+64,:)';
    end
    
    if flg1==0
        flg1=1;
    elseif flg1==1
        flg1=0;
        v2=[v2(65:128);v2(1:64)];
    end
    
    v3=fftshift(ifft(v2));
        %v1_s128(30:36)=v4_s4(2:8,nn);
        %v1_s128(50:74)=v4_s32(5:29,nn);
        %v1_s128(85:4:108)=y1(:,nn);
    v4(80:86)=v3(30:36);
    v4(26:50)=v3(50:74);
    v4(60:71)=v3(84:95);
    v4(90:101)=v3(96:107);

    v5=128*ifft(fftshift(v4));
    
    if flg2==0
        flg2=1;
    elseif flg2==1
        flg2=0;
        v5=[v5(65:128);v5(1:64)];
    end
    
    reg_b=[v5 reg_b(:,1:27)];
    
    for kk=1:64
        p1=reg_b(kk,1:2:28)*hh128(kk,:)';
        p2=reg_b(kk+64,2:2:28)*hh128(kk+64,:)';
        y128(m2+kk)=(p1+p2);
    end
    m2=m2+64;
end


figure(7)
subplot(2,1,1)
plot(real(y128(2001:6000)))
grid on
title('Composite Time Series')

subplot(2,1,2)
ww=kaiser(4096,12)';
ww=2*ww/sum(ww);
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(y128(4001:8096).*ww)))))
hold on
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(h128/64,4096)))),'r')
hold off
grid on
axis([-64 64 -120 10])
title('Spectrum from Analysis, Rearrange, and Synthesis Channelizer')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')

% Now demodulate

reg_a=zeros(128,28);
v1=zeros(1,128)';
v2=zeros(1,128)';
v3=zeros(1,128)';
v4=zeros(1,128)';
v5=zeros(1,128)';
v3_sv=zeros(128,400);
yy1=zeros(24,400);
yy4=zeros(7,400);
yy16=zeros(25,400);
m1=1;
flg1=0;

for nn=1:64:25600-63

    v1(1:64)=fliplr(y128(nn:nn+63)).';
    v1(65:128)=v1(1:64);
    reg_a=[v1 reg_a(:,1:27)];
    
    for kk=1:64
        v2(kk)=reg_a(kk,1:2:28)*gg128(kk,:)';
        v2(kk+64)=reg_a(kk+64,2:2:28)*gg128(kk+64,:)';
    end
    
    if flg1==0
        flg1=1;
    elseif flg1==1
        flg1=0;
        v2=[v2(65:128);v2(1:64)];
    end
    
    v3=fftshift(ifft(v2));
    v3_sv(:,m1)=v3;
      
%     v4(80:86)=v3(30:36);
%     v4(26:50)=v3(50:74);
%     v4(60:71)=v3(84:95);
%     v4(90:101)=v3(96:107);
      yy1(:,m1)=[v3(60:71);v3(90:101)];
      yy4(:,m1)=v3(80:86);
      yy16(:,m1)=v3(26:50);
      m1=m1+1;
end


figure(8)
for kk=1:3
subplot(3,3,kk)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy1(kk,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
 if kk==2
        title('Spectra, First set of 3-Adjacent Bin Widths')
    end
end

for kk=1:3
subplot(3,3,kk+3)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy1(kk+4,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
end

for kk=1:3
subplot(3,3,kk+6)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy1(kk+8,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
end

figure(9)
for kk=1:3
subplot(3,3,kk)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy1(kk+12,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
 if kk==2
        title('Spectra, Second Set of 3-Adjacent Bin Widths')
    end
end

for kk=1:3
subplot(3,3,kk+3)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy1(kk+16,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
end

for kk=1:3
subplot(3,3,kk+6)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy1(kk+20,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
end

qq=exp(j*pi*(0:399));
yyy(1,:)=yy1(2,:) +(yy1(1,:) +yy1(3,:)).*qq;
yyy(2,:)=yy1(6,:) +(yy1(5,:) +yy1(7,:)).*qq;
yyy(3,:)=yy1(10,:)+(yy1(9,:) +yy1(11,:)).*qq;
yyy(4,:)=yy1(14,:)+(yy1(13,:)+yy1(15,:)).*qq;
yyy(5,:)=yy1(18,:)+(yy1(17,:)+yy1(19,:)).*qq;
yyy(6,:)=yy1(22,:)+(yy1(21,:)+yy1(23,:)).*qq;

figure(10)
for kk=1:6
    subplot(2,3,kk)
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yyy(kk,:).*w1,512)))))
hold on
plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(hh,512)/sum(hh)))),'r')
hold off
grid on
axis([-1 1 -120 10])
 if kk==2
        title('Reconstructed Spectra, 3-Bin Widths')
    end
end

figure(11)
for kk=1:6
subplot(2,3,kk)
    qq=filter(hh,1,yyy(kk,:))*0.5789;
    plot(qq(1:2:400),'r.')
    grid on
    axis([-1.5 1.5 -1.5 1.5])
    axis('square')
    if kk==2
        title('Eye Diagrams Matched Filter, 3-Bin Widths')
    end
end



% 8-port synthesis filter
h8a=remez(110,[0 0.73 1.27 4.0]/4.0,{'myfrf',[1 1 0 0]},[1 1.01]);
scl_h8=max(h8a);
h8=h8a/scl_h8;

hh8=reshape([0 h8],8,14);

reg_s8=zeros(8,28);
v1_s8=zeros(1,8)';
v2_s8=zeros(1,8)';
yy8=zeros(1,1600);
m2=0;
flg2=0;
for nn=1:400
    v1_s8(2:8)=yy4(:,nn).*exp(j*2*pi*(1:7)*1/64).';
    v2_s8=8*ifft(fftshift(v1_s8));
  
    if flg2==0
        flg2=1;
    elseif flg2==1
        flg2=0;
        v2_s8=[v2_s8(5:8);v2_s8(1:4)];
    end
    
    reg_s8=[v2_s8 reg_s8(:,1:27)];
    
    for kk=1:4
        p1=reg_s8(kk,1:2:28)*hh8(kk,:)';
        p2=reg_s8(kk+4,2:2:28)*hh8(kk+4,:)';
        yy8(m2+kk)=(p1+p2);
    end
    m2=m2+4;
end

figure(12)
ww4=kaiser(400,12)';
subplot(3,4,1)
grid on
    axis([-1 1 -120 10])
ww4=15*ww4/sum(ww4);
for kk=1:7
    subplot(3,4,kk+1)
    plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy4(kk,1:400).*ww4,512)))))
    grid on
    axis([-1 1 -120 10])
end

subplot(3,1,3)
w4=kaiser(1024,12)';
w4=15*w4/sum(w4);
plot((-0.5:1/1024:0.5-1/1024)*8,fftshift(20*log10(abs(fft(yy8(201:1224).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*8,fftshift(20*log10(abs(fft(hh/2,1024)))),'r')
hold off
grid on
axis([-4 4 -120 10])
title('Spectrum, Reconstructed Signal s4(n)')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')

figure(13)
subplot(1,2,1)
plot(yy8(2:2:end)*exp(j*2*pi*0.079),'r.')
grid on
axis('square')
title('Constellation 7 Bin Width of Composite Channelizer')

yyy8=filter(hh,1,yy8);
subplot(1,2,2)
plot(yyy8(2:2:end)*exp(j*2*pi*0.079)/1.71,'r.')
grid on
axis('square')
axis([-1.5 1.5 -1.5 1.5])
title('Constellation Matched Filter')


% 32-port synthesizer

h32a=remez(446,[0 0.73 1.27 16.0]/16.0,{'myfrf',[1 1 0 0]},[1 1.01]);
scl_h32=max(h32a);
h32=h32a/scl_h32;

hh32=reshape([0 h32],32,14);

reg_s32=zeros(32,28);
v1_s32=zeros(1,32)';
v2_s32=zeros(1,32)';
yy32=zeros(1,6400);
m2=0;
flg2=0;
for nn=1:400
    %v1_s32=v4_s32(:,nn);
    v1_s32(5:29)=yy16(:,nn).*exp(j*2*pi*(1:25)*1/64).';
    v2_s32=32*ifft(fftshift(v1_s32));
  
    if flg2==0
        flg2=1;
    elseif flg2==1
        flg2=0;
        v2_s32=[v2_s32(17:32);v2_s32(1:16)];
    end
    
    reg_s32=[v2_s32 reg_s32(:,1:27)];
    
    for kk=1:16
        p1=reg_s32(kk,1:2:28)*hh32(kk,:)';
        p2=reg_s32(kk+16,2:2:28)*hh32(kk+16,:)';
        yy32(m2+kk)=(p1+p2);
    end
    m2=m2+16;
end

figure(14)

ww32=kaiser(400,12)';
ww32=20*ww32/sum(ww32);
vv=[1:7 19:25];
for kk=1:14
    subplot(3,7,kk)
    plot((-0.5:1/512:0.5-1/512)*2,fftshift(20*log10(abs(fft(yy16(vv(kk),1:400).*ww32,512)))))
    grid on
    axis([-1 1 -120 10])
end

subplot(3,1,3)
w32=kaiser(1024,12)';
w32=15*w32/sum(w32);
plot((-0.5:1/1024:0.5-1/1024)*32,fftshift(20*log10(abs(fft(yy32(2001:3024).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*32,fftshift(20*log10(abs(fft(hh/2,1024)))),'r')
hold off
grid on
axis([-16 16 -120 10])
title('Spectrum, Reconstructed Signal s16(n)')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')


figure(15)
subplot(1,2,1)
plot(yy32(2:2:end)*exp(j*2*pi*0.063),'r.')
grid on
axis('square')
title('Constellation 25 Bin Width of Composite Channelizer')

yyy32=filter(hh,1,yy32)/1.715;
subplot(1,2,2)
plot(yyy32(2:2:end)*exp(j*2*pi*0.063),'r.')
grid on
axis('square')
title('Constellation Matched Filter')

figure(20)
subplot(2,1,1)
ww=kaiser(4096,12)';
ww=2*ww/sum(ww);
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(x128(2001:6096).*ww)))))
hold on
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(h128/64,4096)))),'r')
hold off
grid on
axis([-64 64 -120 10])
title('Composite Spectrum from Signal Generator')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')


subplot(2,1,2)
ww=kaiser(4096,12)';
ww=2*ww/sum(ww);
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(y128(4001:8096).*ww)))))
hold on
plot((-0.5:1/4096:0.5-1/4096)*128,fftshift(20*log10(abs(fft(h128/64,4096)))),'r')
hold off
grid on
axis([-64 64 -120 10])
title('Spectrum from Analysis, Rearrange, and Synthesis Channelizer')
xlabel('Normalized Frequency')
ylabel('Log Mag (dB)')



figure(25)
ww4=kaiser(400,12)';
subplot(3,4,1)
grid on
    axis([-100 100 -120 10])
    xlabel('Frequency (MHz)')
    ylabel('Log Mag (dB)')
ww4=15*ww4/sum(ww4);
for kk=1:7
    subplot(3,4,kk+1)
    plot((-0.5:1/512:0.5-1/512)*200,fftshift(20*log10(abs(fft(yy4(kk,1:400).*ww4,512)))))
    grid on
    axis([-100 100 -120 10])
    xlabel('Frequency (MHz)')
    ylabel('Log Mag (dB)')
end

subplot(3,1,3)
w4=kaiser(1024,12)';
w4=15*w4/sum(w4);
plot((-0.5:1/1024:0.5-1/1024)*800,fftshift(20*log10(abs(fft(yy8(201:1224).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*800,fftshift(20*log10(abs(fft(hh/2,1024)))),'r')
hold off
grid on
axis([-400 400 -120 10])
title('Spectrum, 500 MHz Reconstructed Signal Spectrum')
xlabel('Frequency (MHz)')
ylabel('Log Mag (dB)')


figure(26)
ww4=kaiser(400,12)';
subplot(3,4,1)
grid on
    axis([-50 50 -120 10])
    xlabel('Frequency (MHz)')
    ylabel('Log Mag (dB)')
ww4=15*ww4/sum(ww4);
for kk=1:7
    subplot(3,4,kk+1)
    plot((-0.5:1/512:0.5-1/512)*100,fftshift(20*log10(abs(fft(yy4(kk,1:400).*ww4,512)))))
    grid on
    axis([-50 50 -120 10])
    xlabel('Frequency (MHz)')
    ylabel('Log Mag (dB)')
    title('Spectrum: -125 to -75 MHz')
end

subplot(3,1,3)
w4=kaiser(1024,12)';
w4=15*w4/sum(w4);
plot((-0.5:1/1024:0.5-1/1024)*400,fftshift(20*log10(abs(fft(yy8(201:1224).*w4,1024)))))
hold on
plot((-0.5:1/1024:0.5-1/1024)*400,fftshift(20*log10(abs(fft(hh/2,1024)))),'r')
hold off
grid on
axis([-200 200 -120 10])
title('Spectrum, 300 MHz Spectrum Reconstructed Reconstructed from seven 50 MHz Channels')
xlabel('Frequency (MHz)')
ylabel('Log Mag (dB)')
