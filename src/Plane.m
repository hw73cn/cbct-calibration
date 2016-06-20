% This file is part of cbct-calibration, an accurate geometric calibration of cone-beam CT.
%
% https://github.com/Rholais/cbct-calibration
%
% Copyright 2016 Haocheng Li and contributors
%
% License:  Standard 3-clause BSD; see "LICENSE" for full license terms
%           and contributor agreement.

classdef Plane < handle
	%PLANE A class of plane
	%   To descibe a plane's origin and normal.
	%	使用平面上一点与平面的法向量，即点法式描述

	properties (GetAccess = public, SetAccess = private, SetObservable)
		%	平面上一点坐标
		%	$3 \times 1$双精度数组，初始化为0
		Ori = zeros(3, 1);
		
		%	平面的旋转角数组
		%	$1 \times 3$双精度数组，每一位表示一个旋转方向上的旋转角，初始化为0
		Ang = zeros(1, 3);
		
		%	旋转矩阵
		%	$3 \times 3$双精度数组，初始化为单位矩阵
		Rot = eye(3);
		
		%	比例变换系数
		%	$1 \times 3$双精度数组，每一位表示一个坐标方向上的变换比例，初始化为1
		Scl = ones(1, 3);
	end

	methods (Access = public)
		function obj = Plane(ori, ang, scl)
			addlistener(obj, 'Ang', 'PostSet', @obj.onAngChange);
			addlistener(obj, 'Scl', 'PostSet', @obj.onSclChange);
			
			obj.Ori = ori;
			obj.Ang = ang;
			obj.Scl(1:2) = scl;
		end
		
		%	将平面上的坐标转化为空间坐标系中的坐标
		function phtAbs = abs(obj, phtChs)
			phtAbs = [obj.Rot(:, 1:2), obj.Ori] * [phtChs; ones(1, size(phtChs, 2))]; 
		end
		
		%	根据X射线源坐标将空间坐标系中的点的坐标投影到平面上
		function dtcAbs = prj(obj, phtAbs, srcAbs)
			dtcAbs = ones(3, 1) * ((obj.Rot(:, 3)' * (obj.Ori * ones(1, size(phtAbs, 2)) - srcAbs)) ./ (obj.Rot(:, 3)' * (phtAbs - srcAbs))) .* (phtAbs - srcAbs) + srcAbs;
		end
		
		%	将空间坐标系中的坐标转化为平面上的坐标
		function phtChs = chs(obj, phtAbs)
			phtChs = diag([1, 1, 0]) * ([obj.Rot(:, 1:2), obj.Ori] \ phtAbs);
		end
	end

	methods (Access = private)
		function onAngChange(obj, ~, ~)
			r = Plane.rot(obj.Ang(1), obj.Ang(2), obj.Ang(3));
			obj.Rot = r * diag(obj.Scl);
		end
		
		function onSclChange(obj, metaProp, eventData)
			obj.Scl(3) = obj.Scl(1) * obj.Scl(2);
			obj.onAngChange(metaProp, eventData);
		end
	end

	methods (Access = public, Static)
		%	根据三个方向的旋转角计算旋转矩阵
		function r = rot(pitch, roll, yaw)
			r = roty(roll) * rotx(pitch) * rotz(yaw);
		end
		
		function phtChs = prjChs(obj, dtc, dtcChs)
			dtcAbs = dtc.abs(dtcChs);
			phtAbs = obj.prjAbs(dtcAbs);
			phtChs = obj.chs(phtAbs);
		end
	end
		
end

