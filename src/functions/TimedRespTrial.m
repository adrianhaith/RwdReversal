function output = TimedRespTrial(screen, audio, images, resp_device, output, ii);

	% output.block.trial(ii)
	% refer to AllocateData for structure
	output.block.trial(ii).abs_time_on = GetSecs;
	% The audio onset will be used as the "true" trial start

end