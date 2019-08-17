% testMonitorTiming_dotsX_remote
%
%  Software requirements:
%     1. dotsX in REMOTE MODE
%     2. MAKE SURE IP ADDRESSES ARE REPORTED CORRECTLY IN dXudp
%     3. run rRemoteClient on the other machine
%
%  Hardware requirements:
%     1. PMD1208fs
%        https://www.mccdaq.com/usb-data-acquisition/USB-1208FS.aspx
%        see file "pmd1208fs_specs.pdf" for technical specs
%     2. OSI Optoelectronics PIN-10D photodiode.
%        see file "Photoconductive-Photodiodes.pdf" for technical specs
%     3. Cable for connecting photodiode (BNC connector) to PMD device
%        (screw terminals)
%
%  Hardware setup:
%     1. Attach the photodiode to the PMD device. We are using the device
%        in DIFFERENTIAL MODE, with default channel 0. So you should plug
%        the leads into terminals 1 and 2
%     2. Tape or hold the photodiode to the part of the screen where the
%        target will show
%     3. Run the script
%

%% flash for one second
SCREEN_INDEX  = 1;  % 0=small rectangle on main screen; 1=main screen; 2=secondary
NUM_REPS      = 10;
NUM_LUMINANCE = 5;
SHOW_RAW      = true;
SHOW_FITS     = true;
REPORT_FITS   = true;
FRAME_RATE    = 60;

%% setup screen remotely
rInit('remote');
rAdd('dXtarget', 1, 'visible', true, 'diameter', 40);

%% configure device
aIn = AInScan1208FS();
aIn.channels  = 0; % differential channel 0 is inputs 0 & 1
aIn.gains     = 7; % 20x = +/-1V; see MCCFormatReport
aIn.frequency = 2000;

%% Check dark->light and light-dark transitions
if NUM_LUMINANCE == 0
   lums = 0;
else
   lums = linspace(0,0.4,NUM_LUMINANCE);
end
preFrames     = 8;
postFrames    = 8;
nFrames       = preFrames+postFrames;
nSamples      = ceil((preFrames./FRAME_RATE+0.1)*aIn.frequency);
aIn.nSamples  = nSamples.*4;
frameTiming   = nans(nFrames, NUM_LUMINANCE, 2, NUM_REPS);
OSOdata       = nans(nSamples, 2, NUM_LUMINANCE, 2, NUM_REPS);
for ll = 1:NUM_LUMINANCE
   lum_ld = [lums(ll) 1-lums(ll); 1-lums(ll) lums(ll)];
   for dd = 1:2
      for rr = 1:NUM_REPS
         frames = cat(1,repmat(lum_ld(dd,1),preFrames,1),repmat(lum_ld(dd,2),postFrames,1));
         configTime = aIn.prepareToScan();
         startTime  = aIn.startScan(); % host CPU time, when start ack'd by USB device
         for ii = 1:nFrames
            rSet('dXtarget', 1, 'color', 255.*ones(1,3).*frames(ii));
            % send message
            rGraphicsDraw;
            % wait for return, which should be timestamp
            frameTiming(ii,ll,dd,rr) = getMsgH(500);
            
            % mexHID('check');
         end
         pause(0.2);
         mexHID('check'); % probably not necessary...
         
         % cleanup
         stopTime = aIn.stopScan();
         [chans, volts, times, uints] = aIn.getScanWaveform();
         t0 = frameTiming(preFrames+1,ll,dd,rr);
         ti = find(times>=(t0-0.01), 1);
         OSOdata(:, :, ll, dd, rr) = [ ...
            (times(ti+(1:nSamples))'-t0).*1000, ...
            volts(ti+(1:nSamples))'];
         frameTiming(:,ll,dd,rr) = frameTiming(:,ll,dd,rr) - t0;
      end
   end
end

% clean up
rDone(1);
aIn.close();

%% Plot raw data
if SHOW_RAW
   figure
   hold on
   for ll = 1:NUM_LUMINANCE
      for dd = 1:2
         subplot(NUM_LUMINANCE,2,(ll-1)*2+dd); cla reset; hold on;
         title(sprintf('Luminance = %.2f', lums(ll)))
         for rr = 1:NUM_REPS
            startTime = frameTiming(5,ll,dd,rr);
            plot(OSOdata(:,1,ll,dd,rr), OSOdata(:,2,ll,dd,rr), '-', ...
               'Color', lums(ll).*ones(1,3))
            for ff = 1:size(frameTiming,1)
               plot((frameTiming(ff,ll,dd,rr)).*1000.*[1 1], [0 1], 'r-');
            end
            plot((frameTiming(preFrames+1,ll,dd,rr)).*1000.*[1 1], [0 1], 'b-');
         end
         axis([-20 150 0.20 0.36]);
      end
   end
end

%% fit to piecewise function, with exponential
if SHOW_FITS || REPORT_FITS
   
   % get fits
   global data
   inits = [40 0.3 10 0.35; 0 0 0.1 0; 100 1 20 1];
   fits = nans(NUM_REPS,size(inits,2),NUM_LUMINANCE,2);
   for ll = 1:NUM_LUMINANCE
      for rr = 1:NUM_REPS
         for dd=1:2
            Lt = OSOdata(:,1,ll,dd,rr)>0 & OSOdata(:,1,ll,dd,rr)<120;
            times = OSOdata(Lt,1,ll,dd,rr);
            volts = OSOdata(Lt,2,ll,dd,rr);
            yStartg = volts(1);
            yEndg   = volts(end);
            [Y,I]   = max(abs(diff(nanrunmean(volts,5))));
            tStartg = min(times(I));
            data    = OSOdata(Lt,:,ll,dd,rr);
            [ff, fval, exitflag, output] = patternsearch(@expFitErr,...
               [tStartg yStartg 3 yEndg],[],[],[],[],inits(2,:),inits(3,:),[], ...
               psoptimset('Display', 'off'));
            fits(rr,:,ll,dd) = ff;
            
            %             cla reset; hold on;
            %             plot(times, volts, 'k-');
            %             plot(times, valFIT_piecewiseEXP(ff(1), ff(2), ff(3), ff(4), times), 'r-');
            %             axis([0 120 0.3 0.38]);
            % r = input('next')
         end
      end
   end
   
   % report
   if REPORT_FITS
      for ll = 1:NUM_LUMINANCE
         disp(sprintf('Lum=%.2f: dark->light = %.2f ms delay, %.2f rise time', ...
            lums(ll), median(fits(:,1,ll,1)), median(fits(:,3,ll,1))))
         disp(sprintf('Lum=%.2f: light->dark = %.2f ms delay, %.2f rise time', ...
            lums(ll), median(fits(:,1,ll,2)), median(fits(:,3,ll,2))))
      end
   end
   
   if SHOW_FITS
      %% plot fits
      figure
      hold on
      lm = [0 50; 0 20];
      params = [1 3];
      nParams = length(params);
      for pp = 1:nParams
         for dd = 1:2 % dark->light, light->dark
            subplot(nParams,2,(dd-1)*2+pp); cla reset; hold on;
            plot(fits(:,params(pp),1,dd), 'k.', 'MarkerSize', 10);
            %         for ll = 1:NUM_LUMINANCE
            %             plot(ll, fits(:,params(pp),ll,dd), 'k.');
            %             plot(ll, median(fits(:,params(pp),ll,dd)), 'r.', 'MarkerSize', 10);
            %         end
            axis([0 NUM_LUMINANCE+1 lm(pp,:)])
         end
      end
   end
end




