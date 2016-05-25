function output = TimedRespTrial(screen, audio, images, resp_device, ...
                                 press_feedback, tgt, output, ii);

	% output.block.trial(ii)
	% refer to AllocateData for structure
	temp_presses(1:3) = struct('index', int16(-1), 'rel_time_on', -1,...
						       'rel_time_off', -1, 'abs_time_on', -1, ...
						       'abs_time_off', -1);
	press_count = 1;
	updated_screen_press = zeros(1, length(resp_device.valid_indices));
	num_frames = round(1.6/screen.ifi); 
	first_screen_press = updated_screen_press;
	Priority(screen.priority);
	output.block.trial(ii).abs_time_on = GetSecs;
	% The audio onset will be used as the "true" trial start
    WipeScreen(screen);
	DrawOutline(press_feedback, screen.window);
	time_flip = FlipScreen(screen);
	
	WipeScreen(screen);
	DrawOutline(press_feedback, screen.window);
	
	time_audio = time_flip + screen.ifi;
	time_flip2 = time_flip + 0.5 * screen.ifi;
	if img_time < 0
	    img_frame = -1;
		time_image = -1;
	else % not a catch trial
	    % built-in 500 ms of silence on the click train
		img_frame = round((0.5 + tgt.image_time(ii))/screen.ifi);
    end
	
    PlayAudio(audio, 1, time_audio);	
	time_flip3 = FlipScreen(screen, time_flip2);
	StartKeyResponse(resp_device);
	
	for frame = 1:num_frames
	    WipeScreen(screen);
		DrawOutline(press_feedback, screen.window);
		
		if frame >= img_frame
		    DrawImage(images, tgt,image_index(ii), screen.window);
			if frame == img_frame
			    save_image_time = true;
			else
			    save_image_time = false;
			end
	    end
		
		% check keyboard
		temp_press = [-1 -1];
		[temp_press, updated_screen_press] = CheckKeyResponse(resp_device, updated_screen_press);
		if temp_press(1) > 0 && press_count < 4
		    temp_presses(press_count).index = temp_press(1);
			temp_presses(press_count).abs_time_on = temp_press(2);
			temp_presses(press_count).rel_time_on = temp_press(2) - time_audio;
			
		    if press_count == 1
			    first_screen_press = updated_screen_press;
		    end
			press_count = press_count + 1;
		end
		% draw temporary feedback
		DrawFill(press_feedback, screen.window, 'gray', updated_screen_press, 0);
		
		time_flip3 = FlipScreen(screen, time_flip3 + 0.5*screen.ifi);
		if save_image_time
		    time_image = time_flip3;
		end
	
	end

		
	Priority(0);
	if class(resp_device) == 'ForceResponse'
	    [force_traces, timestamp] = CheckFullResponse(resp_device);
		output.block.trial(ii).forces = [timestamp; force_traces]; % check dims!
    else
		output.block.trial(ii).forces = []; % saves space
	end
	
	StopKeyResponse(resp_device);
	output.block.trial(ii).images.abs_time_on = time_image;
	output.block.trial(ii).images.index = tgt.image_index(ii);
	output.block.trial(ii).images.rel_time_on = time_image - ref_time;
	output.block.trial(ii).sounds.abs_time_on = time_audio;
	output.block.trial(ii).sounds.rel_time_on = time_audio - ref_time;
	temp_presses(structfind(temp_presses, 'rel_time_on', -1)) = []; % prune unused fields (should have at least one)
	output.block.trial(ii).presses = temp_presses;
end