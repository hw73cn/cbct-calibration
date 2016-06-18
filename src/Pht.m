classdef Pht < handle
	%PHANTOM The calibration phantom
	%   The calibration phantom consists of a precise arrangements within 
	%   25 \textmu m machining tolerancesd of 24 steel ball bearings (BBs) 
	%   embedded in a cylindrical plastic phantom

	properties (GetAccess = public, SetAccess = private)
		%   Number of sets of Bbs
		CpN = 0;        
		%   D of each set
		CpD = 0;
		%   Number of Bbs in each set
		BbN = 0;
		%   D of Bbs
		BbD = 0;
		%   Distance of each set
		Dst = 0;
		% Array of Bbs
		BbA = [];
	end

	methods (Access = public)
		function obj = Pht(cpN, cpD, bbN, bbD, dst, bbA)
			obj.CpN = cpN;
			obj.CpD = cpD;
			obj.BbN = bbN;
			obj.BbD = bbD;
			obj.Dst = dst;
			obj.BbA = bbA;
		end
		
		function ax = draw(obj)
			plot3(obj.BbA(1, :), obj.BbA(2, :), obj.BbA(3, :), 'ok');
			ax = gca;
			ax.DataAspectRatio = [1, 1, 1];
		end
		
		function [ Dat ] = datGen( obj, rFI, rFD, angX, angY, angZ, gantry )
		%DATGEN Summary of this function goes here
		%   Detailed explanation goes here
			src = [0; 0; rFI];
			dtc = Plane([0; 0; rFI - rFD ], [angX, angY, angZ], [1, 1]);
			cbct = Cbct(src, obj, dtc);
			Dat = cbct.prj(gantry);
			delete(dtc);
			delete(cbct);
		end
	end

end

