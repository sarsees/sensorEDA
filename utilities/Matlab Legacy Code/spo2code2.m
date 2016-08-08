clear
clc
close all;

%Inputs
path = '2016_7_13_17_28_31_MAX30100_COW129.csv';
path = 'C:\Vet\simulated_tests\simulated_tests\raw\heavy_breathing\2000_1_1_0_34_33_MAX30100_COW#.csv'
window_width = 128;
window_overlap = 64;

%Pull in the raw information
raw = fileread(path);

%Split it according to delimiter
delimiter = '!@#\n';
temp = strsplit(raw,delimiter);
originalHeader = temp{1};
CSVHeader = temp{2};
datapoints = textscan(temp{2},'%s','delimiter','\n');
datapoints = datapoints{1};

%Get the IR, Red, temp, and time values
ir_all = [];
red_all = [];
temp_all = [];
t_all = [];
for i =20:numel(datapoints)
    currentDatapoint = textscan(datapoints{i},'%f%f%f%f','delimiter',',');
    
    ir_all(end+1) = currentDatapoint{1};
    red_all(end+1) = currentDatapoint{2};
    temp_all(end+1) = currentDatapoint{3};
    t_all(end+1) = currentDatapoint{4};
end
% ir_all = ir_all';
% red_all = red_all';
% temp_all = temp_all';
% t_all = t_all';

% clearvars -except window_width window_overlap
% load('C:\Users\luzi363\Documents\MATLAB\m49715_1.1\pulseOxData.mat')
% ir_all = I_ir;
% red_all = I_red;
% Fs = fs;
% Ts = 1/fs;
% t_all = linspace(0,Ts*length(ir_all),length(ir_all));

for window = 1:floor((length(ir_all) - window_width)/(window_overlap) )
    %Indices
    ind_start = (window-1)*(window_width-window_overlap) + 1;
    ind_end = ind_start + window_width - 1;
    ir = ir_all(ind_start:ind_end);
    red = red_all(ind_start:ind_end);
    t = t_all(ind_start:ind_end);

    %Constants
    e_ro = 319.6;
    e_rd = 3226.56;
    e_iro = 1154;
    e_ird = 726.44;

%     %Constants
%     e_ro = 442;
%     e_rd = 4345.2;
%     e_iro = 1214;
%     e_ird = 693.44;

    %Plot
    figure();
    subplot(2,1,1);
    plot(t,ir); title('IR'); xlabel('Time (s)'); ylabel('Counts');
    subplot(2,1,2);
    plot(t,red); title('RED'); xlabel('Time (s)'); ylabel('Counts');

    %Take fft of ir
    Ts = t(end)/(length(t)-1);
    Fs = 1/Ts;
    L = length(t);
    NFFT = 2^nextpow2(L);
    fft_ir = fft(ir,NFFT)/L;
    fft_red = fft(red,NFFT)/L;
    f = Fs/2*linspace(0,1,NFFT/2+1);

    %I averages
    fl = .5;
    fu = 4;
    indices = find(f > fl & f < fu );
    ir_frame = fft_ir(:);
    I_ir_ac =  max(abs(ir_frame(2:end)));
    I_ir_dc = abs(fft_ir(1));
    red_frame = fft_red(:);
    I_r_ac = max(abs(red_frame(2:end)));
    I_r_dc = abs(fft_red(1));

    %Calculate the std AC Values
    I_ir_std = std(ir);
    I_r_std = std(red);
    
    %Calculate the peak values
    [tops,~] = findpeaks(red,1,'MinPeakDistance',20);
    [bots,~] = findpeaks(-red,1,'MinPeakDistance',20);
    bots = (-1).*bots;
    I_D_red = mean(tops);
    I_S_red = mean(bots);
    [tops,~] = findpeaks(ir,1,'MinPeakDistance',20);
    [bots,~] = findpeaks(-ir,1,'MinPeakDistance',20);
    bots = (-1).*bots;
    I_D_ir = mean(tops);
    I_S_ir = mean(bots);
    
    %Calculate hamming window
    red_h = red.*hamming(length(red))';
    fft_red_h = fft(red_h,NFFT)/L;
    ir_h = ir.*hamming(length(ir))';
    fft_ir_h = fft(ir_h,NFFT)/L;
    %I averages
    I_ir_ac_h =  norm(abs(fft_ir_h(2:end)));
    I_ir_dc_h = abs(fft_ir_h(1));
    I_r_ac_h =   norm(abs(fft_red_h(2:end)));
    I_r_dc_h = abs(fft_red_h(1));

    % %Plot ffts
    % subplot(2,2,2);
    % plot(f(:),2*abs(fft_ir(1:NFFT/2+1)))
    % title('IR FFT'); xlabel('Frequency (Hz)'); ylabel('Magnitude');
    % subplot(2,2,4);
    % plot(f(:),2*abs(fft_red(1:NFFT/2+1)))
    % title('RED FFT'); xlabel('Frequency (Hz)'); ylabel('Magnitude');

%     %Plot amplitude
%     subplot(2,1,1);
%     hold on;
%     plot(t,linspace(I_ir_dc + I_ir_ac,I_ir_dc + I_ir_ac,length(t)));
%     plot(t,linspace(I_ir_dc - I_ir_ac,I_ir_dc - I_ir_ac,length(t)));
%     subplot(2,1,2);
%     hold on;
%     plot(t,linspace(I_r_dc + I_r_ac,I_r_dc + I_r_ac,length(t)));
%     plot(t,linspace(I_r_dc - I_r_ac,I_r_dc - I_r_ac,length(t)));

    %Calculate R
    R = (I_r_ac/I_r_dc)/(I_ir_ac/I_ir_dc);
    R_std = (I_r_std/I_r_dc)/(I_ir_std/I_ir_dc);
    R_example = (abs(max(fft_red(6:12)))/abs(fft_red(1)))/ ...
                (abs(max(fft_ir(6:12)))/abs(fft_ir(1)));
    R_ds = ((I_D_red-I_S_red)/I_S_red)/((I_D_ir-I_S_ir)/I_S_ir);
    R_hamming = (I_r_ac_h/I_r_dc_h)/(I_ir_ac_h/I_ir_dc_h);

    %Calculate spo2
    spo2(window) = (e_rd - R*e_ird)/(R*(e_iro-e_ird) - (e_ro-e_rd));
    spo2_std(window) = (e_rd - R_std*e_ird)/(R_std*(e_iro-e_ird) - (e_ro-e_rd));
    spo2_example(window) = 1.04-.28*R_example;
    spo2_ds(window) = (e_rd - R_ds*e_ird)/(R_ds*(e_iro-e_ird) - (e_ro-e_rd));
    spo2_hamming(window) = (e_rd - R_hamming*e_ird)/(R_hamming*(e_iro-e_ird) - (e_ro-e_rd));
    
%     disp(['IR AC: ' num2str(I_ir_ac)])
%     disp(['IR max - min: ' num2str(max(ir)-min(ir))])
%     disp(['RED AC: ' num2str(I_r_ac)])
%     disp(['RED max - min: ' num2str(max(red)-min(red))])
%     disp(['R: ' num2str(R)])
%     disp(['SpO2: ' num2str(spo2)])
    close all;
end

window_time = linspace(t_all(1),t_all(end),length(spo2));
figure();
subplot(5,1,1);
plot(window_time,spo2);
title('SpO2 (Normal) vs time');
xlabel('Time (s)');
ylabel('SpO2 (%)');
ylim([0,1]);
subplot(5,1,2);
plot(window_time,spo2_std);
title('SpO2 (Std) vs time');
xlabel('Time (s)');
ylabel('SpO2 (%)');
ylim([0,1]);
subplot(5,1,3);
plot(window_time,spo2_example);
title('SpO2 (Example) vs time');
xlabel('Time (s)');
ylabel('SpO2 (%)');
ylim([0,1]);
subplot(5,1,4);
plot(window_time,spo2_ds);
title('SpO2 (DS) vs time');
xlabel('Time (s)');
ylabel('SpO2 (%)');
ylim([0,1]);
subplot(5,1,5);
plot(window_time,spo2_hamming);
title('SpO2 (Hamming) vs time');
xlabel('Time (s)');
ylabel('SpO2 (%)');
ylim([0,1]);

%Info on each spo2 method
disp(['spo2 normal: '  num2str(mean(spo2))])
disp(['spo2 std: '  num2str(mean(spo2_std))])
disp(['spo2 example: '  num2str(mean(spo2_example))])
disp(['spo2 ds: '  num2str(mean(spo2_ds))])
disp(['spo2 hamming: '  num2str(mean(spo2_hamming))])