% This file is part of cbct-calibration, an accurate geometric calibration of cone-beam CT.
%
% https://github.com/Rholais/cbct-calibration
%
% Copyright 2016 Haocheng Li and contributors
%
% License:  Standard 3-clause BSD; see "LICENSE" for full license terms
%           and contributor agreement.

%function [ output_args ] = ftrGen( input_args )
%FTRGEN Generate features
%   Generate features for fit

	clear

	maxBbN = 18;  
	maxAsp = 8;
	NUM = 21000;

	ftr = zeros(2 * maxBbN * maxAsp, NUM, 6, 6);
	lbl = zeros(2, NUM);
	ang = zeros(3, NUM);

	lbl(1, :) = normrnd(200, 1, [1, NUM]);
	lbl(2, :) = normrnd(400, 1, [1, NUM]);
	ang(1, :) = normrnd(0, 5, [1, NUM]);
	ang(2, :) = normrnd(0, 5, [1, NUM]);
	ang(3, :) = normrnd(0, 5, [1, NUM]);

	for i = 1:6
		bbN = 2 * i + 6;
		pht = RndPht(100, bbN, 4.7);
		for j = 1:6
			asp = j + 2;
			Dat = zeros(3, bbN * asp);
			tic
			for k = 1:NUM 
				for l = 1:asp
					Dat(:, (l - 1) * bbN + 1:l * bbN) = pht.datGen(lbl(1, k), lbl(2, k), ang(1, k), ang(2, k), ang(3, k), 180 * (l - (asp + 1) / 2) / asp);
				end
				ftr(1:bbN * asp, k, j, i) = Dat(1, :);
				ftr(bbN * asp + 1:2 * bbN * asp, k, j, i) = Dat(2, :);
			end
			t = toc;
			clear Dat
			fprintf('time of computation for [%d, %d]: %f\n', i, j, t);
		end
		delete(pht);
	end

	save('data.h5', 'ftr', 'ang', '-double');

%end

