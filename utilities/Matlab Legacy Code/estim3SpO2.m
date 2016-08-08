function [SpO2,SpO22,SpO2Cap,HR]=estim3SpO2(ir,red,t,label)
%stuff=[];
%conversion for time:
%t=t-t(1);
%what is the minimum peak distance between peaks we actually care about
%(that is, those needed to compute Heart rate and SpO2 values). We need to
%know so that we are not picking up noise. If the signal is extremely
%noisy, it is not likely we will be able to get anything meaningful. We
%can filter and smooth the signal all we want, if the signal is garbage, we
%will not be able to get good responses. That said, maybe certain
%activities can be distinguished by a very noisy signal so, not all is
%lost. Just almost all.
pkdst=20;
linpts=2*numel(t);


%Molar extinction coefficients of Hemoglobin in water, obtained from an
%reference. It has been reported in the literature that these values have
%uncertainties associated with them. There are papers that show some of
%them. In the end, to make things simpler, we will probably need to pick
%fixed values that seem more or less ok with several references. The
%MAX30100 sensor has 'typical' wavelength values of 880 nm for IR and 660
%for Red.


%     %Constants
         e_ro = 319.6; %at 660nm
         e_rd = 3226.56; %at 660nm
         e_iro = 1154; %at 880 nm
         e_ird = 726.44; %at 880nm

   %e_ro = 442; %at 640 nm
   %e_rd = 4345.2; %at 640NM
   %e_iro = 1214; %at 940nm
   %e_ird = 693.44; %at 940nm

t2=linspace(t(1),t(end),linpts);

%Creating interpolations. I am doing this to have a smooth signal to read
%from at uniform time intervals. If the signal is sampled accurately, at
%fixed (more or less) intervals then we should be able to save some time
%and not do this step, since output from this step is only used to
%calculate peaks and valleys of the signal.

vqir=interp1(t,ir,linspace(t(1),t(end),linpts),'pchip');
vqred=interp1(t,red,linspace(t(1),t(end),linpts),'pchip');

%Finding peaks to calculate Heart Rate and SpO2 values

[pkstopsir,locstopsir] = findpeaks(vqir,'MinPeakDistance',pkdst);
[pkstopsred,locstopsred] = findpeaks(vqred,'MinPeakDistance',pkdst);

[pksbotsir,locsbotsir] = findpeaks(-vqir,'MinPeakDistance',pkdst);
[pksbotsred,locsbotsred] = findpeaks(-vqred,'MinPeakDistance',pkdst);


%These are for AC calculations:
% [pkstopsir,locstopsir] = findpeaks(ir,'MinPeakDistance',pkdst);
% [pkstopsred,locstopsred] = findpeaks(red,'MinPeakDistance',pkdst);
% 
% [pksbotsir,locsbotsir] = findpeaks(-ir,'MinPeakDistance',pkdst);
% [pksbotsred,locsbotsred] = findpeaks(-red,'MinPeakDistance',pkdst);

%Calculating a heart rate value from the IR signal

HRir=60*numel(pkstopsir)/(t(end)-t(1));

Iirac=mean(mean(pkstopsir)+mean(pksbotsir));
Iredac=mean(mean(pkstopsred)+mean(pksbotsred));

%Calculation of R and SpO2 from capstone project document
R2=(Iredac*abs(mean(pksbotsir)))/(Iirac*abs(mean(pksbotsred)));
SpO2Cap=98.283+26.871*R2-52.887*R2^2+10.0002*R2^3;

%Calculating a heart rate value from the Red signal
HRred=60*numel(pkstopsred)/(t(end)-t(1));

%Averaging both to calculate an HR estimate
HR=0.5*(HRir+HRred);


%For DC (maybe):
irmean=mean(ir);
redmean=mean(red);

%R and SpO2 calculations from 'traditional' approach
%This is really ad hoc. The traditional approach should be done using the
%fft code Lorenzo implemented with the Hamming window and stuff. From what
%I've seen, the way I have it implemented here produces the least reliable
%SpO2 values.
R=(Iredac/redmean)/(Iirac/irmean);
SpO2=100*(e_rd-R*e_ird)/(R*(e_iro-e_ird)-(e_ro-e_rd));
%This is just a calibration equation I found
SpO22=110-25*R;

% figure;
% 
% subplot(2,1,1);
% plot(t,ir,'b');xlabel('time, s');ylabel('Infrared counts');
% hold on;plot(t(locstopsir),pkstopsir,'g^');
% hold on;plot(t(locsbotsir),-pksbotsir,'k^');
% title(label);
% 
% subplot(2,1,2);plot(t,red,'r');xlabel('time, s');ylabel('Red counts');
% hold on;plot(t(locstopsred),pkstopsred,'g^');
% hold on;plot(t(locsbotsred),-pksbotsred,'k^');

%comment lines below to suppress plots.

figure;

subplot(2,1,1);
plot(t2,vqir,'b');xlabel('time, s');ylabel('Infrared counts');
 hold on;plot(t2(locstopsir),pkstopsir,'g^');
 hold on;plot(t2(locsbotsir),-pksbotsir,'k^');
title(label);

subplot(2,1,2);plot(t2,vqred,'r');xlabel('time, s');ylabel('Red counts');
 hold on;plot(t2(locstopsred),pkstopsred,'g^');
 hold on;plot(t2(locsbotsred),-pksbotsred,'k^');




