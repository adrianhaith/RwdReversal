function output = main(tgt_path)

    try
        % Get important things into memory
		WaitSecs(0.001);
		GetSecs;
		Screen('preference', 'verbosity', 1);
        warning('off', 'all');
		addpath('src');
		
        % boilerplate initialization
        consts = Constants;
        ui = UserInputs;
        audio = PsychAudio(10);
        aud_dir = 'misc/sounds/';
        images = PsychImages(num_images, 'reversed', consts.reversed, 'scale', consts.scale);
        screen = PsychScreen('reversed', consts.reversed, 'big_screen', consts.big_screen, ...
                             'skip_tests', consts.skip_tests);
		output = AllocateData; % allocates for one block
		
        if nargin == 0
            tgt_path = ['misc/tfiles/', ui.tgt_name];
        end
		[tgt, header, rest] = ParseTgt(tgt_path, ',');
        output.tfile_header = header;
		output.tfile = rest;
        output.image_type = ifelse(tgt.image_type(1), 'letters', 'hands');
        output.swapped = tgt.swapped(1);
        
        
		HideCursor;
		
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
					
		% add headers
		fid = fopen(filename, 'wt');
        csvFun = @(str)sprintf('%s, ', str);
        xchar = cellfun(csvFun, headers, 'UniformOutput', false);
        xchar = strcat(xchar{:});
        xchar = strcat(xchar(1:end-1), '\n');
        fprintf(fid, xchar);
        fclose(fid);
		
        if strfind(tgt_path, 'tr_')
            output.block_type = 'tr';
            FillAudio(aud, [aud_dir, 'beepTrainFast.wav'], 1);
            FillAudio(aud, [aud_dir, 'smw_coin.wav'], 2);
            % use timed response experiment
        elseif strfind(tgt_path, 'rt_')
            output.block_type = 'rt';
            FillAudio(aud, [aud_dir, 'beep.wav'], 1);
            aud_names = dir([aud_dir, 'orch*.wav']);
            for ii = 1:length(aud_names)
                FillAudio(aud, [aud_dir, aud_names(ii)], ii);
            end
            
            % use serial reaction time experiment
        else
            error('unrecognized experiment');
        end
        
		if IsOctave
		    save('-mat7-binary', filename, 'output');
		else
		    save(filename, 'output', '-v7');
		end
		ShowCursor;
		
    catch
        PsychPurge;
    end

end