function output = main(tgt_path)

    try
        % Get important things into memory
		WaitSecs(0.001);
		GetSecs;
	    HideCursor;
		Screen('preference', 'verbosity', 1);
        warning('off', 'all');
		addpath(genpath('src'));
		
        % boilerplate initialization
        consts = Constants;
        ui = UserInputs;
        audio = PsychAudio(10);
        aud_dir = 'misc/sounds/';
        screen = PsychScreen('reversed', consts.reversed, 'big_screen', consts.big_screen, ...
                             'skip_tests', consts.skip_tests);
		output = AllocateData; % allocates for one block
		
        if nargin == 0
            tgt_path = ['misc/tfiles/', ui.tgt_name];
        end
		[tgt, header, rest] = ParseTgt(tgt_path, ',');
        output.tfile_header = header;
		output.tfile = rest;
        output.image_type = ifelse(tgt.image_type(1), 'shapes', 'hands');
        output.swapped = tgt.swapped(1);
		output.day = tgt.day(1);
		output.block_num = tgt.block(1);
        
		subdir = ifelse(tgt.image_type(1), 'shapes', 'hands');
        img_dir = ['misc/images', subdir];
        img_names = dir([img_dir, '/*.jpg']);
        images = PsychImages(length(img_names),...
                             'reversed', consts.reversed,...
                             'scale', consts.scale);

        
        for ii = 1:length(img_names)
            images = ImportImage(images, [img_dir, img_names(ii).name], ...
                                 ii, screen.window, screen.dims(1));
        end
		% swap indices if true
	    if tgt.swapped(1)
		    ind1 = tgt.swap_index_1(1);
			ind2 = tgt.swap_index_2(1);
			images.raw_images{ind2, ind1} = images.raw_images{ind1, ind2};
		    images.ptb_images(ind2, ind1) = images.ptb_images(ind1, ind2);
		end
		
        if ui.keyboard_or_force
            resp_device = KeyboardResponse(valid_indices,...
                                           'possible_keys', consts.possible_keys, ...
                                           'timing_tolerance', consts.timing_tolerance,...
                                           'force_min', consts.force_min,...
                                           'force_max', consts.force_max);
        else
            resp_device = ForceResponse(valid_indices,...
                                        'sampling_freq', consts.sampling_freq,...
                                        'force_min', consts.force_min, ...
                                        'force_max', consts.force_max, ...
                                        'timing_tolerance', consts.timing_tolerance);
        end
		
		% use the date in the filename to prevent overwrites
		date_string = datestr(now, 30);
		date_string = date_string(3:end - 2);
		tfile_string = tgt_path((max(strfind(tgt_path, '/'))+1):end - 4);
		filename = ['data/id', num2str(ui.subject_id), '_', tfile_string, ...
		            '_', date_string, '.mat'];
					

		
        if strfind(tgt_path, 'tr_')
            output.block_type = 'tr';
            FillAudio(aud, [aud_dir, 'beepTrainFast.wav'], 1);
            FillAudio(aud, [aud_dir, 'smw_coin.wav'], 2);
			
			for ii = 1:max(tgt.trial)
			    output = TimedRespTrial(screen, audio, images, resp_device, output, ii);
			end
            
        elseif strfind(tgt_path, 'rt_')
            cccombo = 0; % keep track of current streak
			max_cccombo = 0; % keep track of max streak
			correct_counter = 0; % keep track of # correct (for P(correct) later)
			tttime = GetSecs;
            output.block_type = 'rt';
            FillAudio(aud, [aud_dir, 'beep.wav'], 1);
            aud_names = dir([aud_dir, 'orch*.wav']);
            for ii = 1:length(aud_names)
                FillAudio(aud, [aud_dir, aud_names(ii)], ii);
            end
            
			for ii = 1:max(tgt.trial)
                [output, cccombo] = RapidTrial(screen, audio, images, resp_device, output, cccombo, ii);
			    max_cccombo = ifelse(cccombo > max_cccombo, cccombo, max_cccombo);
			end
			
			final_time = GetSecs - tttime;
			final_percent = correct_counter/max(tgt.trial);
        else
            error('unrecognized experiment');
        end % end trial calls
        
		% save data to mat file (and convert to flat?)
		if IsOctave
		    save('-mat7-binary', filename, 'output');
		else
		    save(filename, 'output', '-v7');
		end
		PsychPurge;
		
    catch
        PsychPurge;
    end

end