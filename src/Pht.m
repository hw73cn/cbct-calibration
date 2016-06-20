% This file is part of cbct-calibration, an accurate geometric calibration of cone-beam CT.
%
% https://github.com/Rholais/cbct-calibration
%
% Copyright 2016 Haocheng Li and contributors
%
% License:  Standard 3-clause BSD; see "LICENSE" for full license terms
%           and contributor agreement.

classdef Pht < handle
	%PHANTOM The calibration phantom
	%   The calibration phantom consists of a precise arrangements within 
	%   25 \textmu m machining tolerancesd of 24 steel ball bearings (BBs) 
	%   embedded in a cylindrical plastic phantom
	%	\textmu CT几何标定中的核心

	properties (GetAccess = public, SetAccess = private)
		%   Number of sets of Bbs
		%	体模中钢珠组合的相同模式数量
		%	16位整数，初始化为1
		CpN = 1;        
		
		%   D of each set
		%	钢珠组合模式的直径
		%	浮点类型，初始化为0
		CpD = 0;
		
		%   Number of Bbs in each set
		%	每个模式中的钢珠数量
		%	16位整数，初始化为0
		BbN = 0;
		
		%   D of Bbs
		%	每个钢珠的直径
		%	浮点类型，初始化为0
		BbD = 0;
		
		%   Distance of each set
		%	钢珠组合模式之间的距离
		%	浮点类型，初始化为0
		Dst = 0;
		
		%	Array of Bbs
		%	体模中所有钢珠的位置坐标数组
		%	双精度二维数组
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
		
		%	绘制标定体模中钢珠在3维笛卡尔坐标系中的分布
		function ax = draw(obj)
			plot3(obj.BbA(1, :), obj.BbA(2, :), obj.BbA(3, :), 'ok');
			ax = gca;
			ax.DataAspectRatio = [1, 1, 1];
		end
		
		%	生成对应的特征数组
		function Dat = datGen( obj, rFI, rFD, angX, angY, angZ, gantry )
			src = [0; 0; rFI];
			dtc = Plane([0; 0; rFI - rFD ], [angX, angY, angZ], [1, 1]);
			cbct = Cbct(src, obj, dtc);
			Dat = cbct.prj(gantry);
			delete(dtc);
			delete(cbct);
		end
	end

end

