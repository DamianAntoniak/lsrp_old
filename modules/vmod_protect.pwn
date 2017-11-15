// This converts a vehicle number to a single bit

#define V(%1) \
	1 << (%1-400 & 0x1F)

public OnVehicleMod(playerid,vehicleid, componentid)
{
	RemoveVehicleComponent(vehicleid,componentid);
	return 0;
	//return CanVehicleHasComponent(vehicleid, componentid);
}

stock CanVehicleHasComponent(vehicleid, componentid)
{
 // Declare the array of bits.
	// Each of the first dimensions are
	// the information for a given mode.
	// The BITS in the second dimension
	// represent which vehicle has it.
	static const
		cs_bMods[194][7] =
		{
			// 1000 - Spoiler Pro - Certain Transfender cars
			{
				V(404) | V(405) | V(421),
				0,
				V(489) | V(492),
				V(505) | V(516),
				V(547),
				V(589),
				0
			},
			// 1001 - Spoiler Win - Certain Transfender cars
			{
				V(401) | V(405) | V(410) | V(415) | V(420) | V(426),
				V(436) | V(439),
				0,
				V(496) | V(518) | V(527),
				V(529) | V(540) | V(546) | V(549) | V(550),
				V(580) | V(585),
				V(603)
			},
			// 1002 - Spoiler Drag - Certain Transfender cars
			{
				V(404) | V(418),
				0,
				V(489),
				V(496) | V(505) | V(516) | V(517),
				V(546) | V(551),
				0,
				0
			},
			// 1003 - Spoiler Alpha - Certain Transfender cars
			{
				V(401) | V(410) | V(415) | V(420) | V(426),
				V(436) | V(439),
				V(491),
				V(496) | V(517) | V(518),
				V(529) | V(547) | V(549) | V(550) | V(551),
				V(585),
				0
			},
			// 1004 - Hood Champ Scoop - Certain Transfender cars
			{
				V(401) | V(420) | V(426),
				0,
				V(478) | V(489) | V(492),
				V(505) | V(516),
				V(540) | V(546) | V(550),
				V(589),
				V(600)
			},
			// 1005 - Hood Fury Scoop - Certain Transfender cars
			{
				V(401) | V(420) | V(426),
				0,
				V(478) | V(489) | V(492),
				V(505) | V(518),
				V(550) | V(551),
				V(589),
				V(600)
			},
			// 1006 - Roof Roof Scoop - Certain Transfender cars
			{
				V(401) | V(418) | V(426),
				V(436),
				V(477) | V(489) | V(492),
				V(496) | V(505) | V(518),
				V(529) | V(540) | V(546) | V(550) | V(551),
				V(580) | V(585) | V(589),
				V(600) | V(603)
			},
			// 1007 - Sideskirt Right Sideskirt - Certain Transfender cars
			{
				V(401) | V(404) | V(410) | V(415) | V(422),
				V(436) | V(439),
				V(477) | V(491),
				V(496) | V(516) | V(517) | V(518) | V(527),
				V(529) | V(540) | V(546) | V(549),
				V(580) | V(585) | V(589),
				V(600) | V(603)
			},
			// 1008 - Nitro 5 times - Most cars, Most planes and Most Helicopters
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1009 - Nitro 2 times - Most cars, Most planes and Most Helicopters
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1010 - Nitro 10 times - Most cars, Most planes and Most Helicopters
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1011 - Hood Race Scoop - Certain Transfender cars
			{
				0,
				0,
				0,
				V(496),
				V(529) | V(549),
				0,
				0
			},
			// 1012 - Hood Worx Scoop - Certain Transfender cars
			{
				0,
				0,
				V(478),
				0,
				V(529) | V(549),
				0,
				0
			},
			// 1013 - Lamps Round Fog - Certain Transfender cars
			{
				V(400) | V(401) | V(404) | V(410) | V(422),
				V(436) | V(439),
				V(478) | V(489),
				V(500) | V(505) | V(518),
				0,
				V(585) | V(589),
				V(600)
			},
			// 1014 - Spoiler Champ - Certain Transfender cars
			{
				V(405) | V(421),
				0,
				V(491),
				V(527),
				V(542),
				0,
				0
			},
			// 1015 - Spoiler Race - Certain Transfender cars
			{
				0,
				0,
				0,
				V(516) | V(527),
				V(542),
				0,
				0
			},
			// 1016 - Spoiler Worx - Certain Transfender cars
			{
				V(404) | V(418) | V(421),
				0,
				V(489) | V(492),
				V(505) | V(516) | V(517),
				V(547) | V(551),
				V(589),
				0
			},
			// 1017 - Sideskirt Left Sideskirt - Certain Transfender cars
			{
				V(401) | V(404) | V(410) | V(415) | V(422),
				V(436) | V(439),
				V(477) | V(491),
				V(496) | V(516) | V(517) | V(518) | V(527),
				V(529) | V(540) | V(546) | V(549),
				V(580) | V(585) | V(589),
				V(600) | V(603)
			},
			// 1018 - Exhaust Upswept - Certain Transfender cars
			{
				V(400) | V(405) | V(415) | V(421),
				0,
				V(477) | V(489) | V(491),
				V(505) | V(516) | V(517) | V(518) | V(527),
				V(529) | V(540) | V(542) | V(546) | V(547) | V(549) | V(550) | V(551),
				V(580) | V(585) | V(589),
				V(600) | V(603)
			},
			// 1019 - Exhaust Twin - Certain Transfender cars
			{
				V(400) | V(401) | V(404) | V(405) | V(410) | V(415) | V(420) | V(421) | V(422) | V(426),
				V(436),
				V(477) | V(489) | V(491),
				V(496) | V(500) | V(505) | V(516) | V(517),
				V(529) | V(540) | V(542) | V(546) | V(547) | V(549) | V(550) | V(551),
				V(585),
				V(603)
			},
			// 1020 - Exhaust Large - Certain Transfender cars
			{
				V(400) | V(401) | V(404) | V(405) | V(410) | V(418) | V(421) | V(422),
				V(436),
				V(477) | V(478) | V(489) | V(491),
				V(496) | V(500) | V(505) | V(516) | V(517) | V(518) | V(527),
				V(529) | V(540) | V(542) | V(547) | V(549) | V(550) | V(551),
				V(580) | V(585) | V(589),
				V(600) | V(603)
			},
			// 1021 - Exhaust Medium - Certain Transfender cars
			{
				V(400) | V(404) | V(405) | V(410) | V(418) | V(420) | V(421) | V(422) | V(426),
				V(436),
				V(477) | V(478) | V(491),
				V(500) | V(516) | V(527),
				V(542) | V(547) | V(551),
				0,
				0
			},
			// 1022 - Exhaust Small - Certain Transfender cars
			{
				0,
				V(436),
				V(478),
				0,
				0,
				0,
				V(600)
			},
			// 1023 - Spoiler Fury - Certain Transfender cars
			{
				V(405) | V(410) | V(415) | V(421),
				V(439),
				V(491),
				V(496) | V(517) | V(518),
				V(529) | V(540) | V(546) | V(549) | V(550) | V(551),
				V(580) | V(585),
				V(603)
			},
			// 1024 - Lamps Square Fog - Certain Transfender cars
			{
				V(400) | V(410),
				0,
				V(478) | V(489),
				V(500) | V(505),
				V(540) | V(546),
				V(589),
				V(603)
			},
			// 1025 - Wheels Offroad - Certain Transfender cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(429) | V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(470) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1026 - Sideskirt Right Alien Sideskirt - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1027 - Sideskirt Left Alien Sideskirt - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1028 - Exhaust Alien - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1029 - Exhaust X-Flow - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1030 - Sideskirt Left X-Flow Sideskirt - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1031 - Sideskirt Right X-Flow Sideskirt - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1032 - Roof Alien Roof Vent - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1033 - Roof X-Flow Roof Vent - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1034 - Exhaust Alien - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1035 - Roof X-Flow Roof Vent - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1036 - SideSkirt Right Alien Sideskirt - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1037 - Exhaust X-Flow - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1038 - Roof Alien Roof Vent - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1039 - SideSkirt Left X-Flow Sideskirt - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1040 - SideSkirt Left Alien Sideskirt - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1041 - SideSkirt Right X-Flow Sideskirt - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1042 - SideSkirt Right Chrome Sideskirt - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1043 - Exhaust Slamin - Broadway
			{
				V(401),
				V(439),
				V(491),
				V(496) | V(517) | V(518),
				V(540) | V(546) | V(547) | V(549) | V(550),
				V(585),
				V(603)
			},
			// 1044 - Exhaust Chrome - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1045 - Exhaust X-Flow - Flash
			{
				V(401),
				V(439),
				V(491),
				V(517) | V(518),
				V(540) | V(542) | V(546) | V(549) | V(550),
				V(585) | V(589),
				V(603)
			},
			// 1046 - Exhaust Alien - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1047 - SideSkirt Right Alien Sideskirt - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1048 - SideSkirt Right X-Flow Sideskirt - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1049 - Spoiler Alien - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1050 - Spoiler X-Flow - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1051 - SideSkirt Left Alien Sideskirt - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1052 - SideSkirt Left X-Flow Sideskirt - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1053 - Roof X-Flow - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1054 - Roof Alien - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1055 - Roof Alien - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1056 - Sideskirt Right Alien Sideskirt - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1057 - Sideskirt Right X-Flow Sideskirt - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1058 - Spoiler Alien - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1059 - Exhaust X-Flow - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1060 - Spoiler X-Flow - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1061 - Roof X-Flow - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1062 - Sideskirt Left Alien Sideskirt - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1063 - Sideskirt Left X-Flow Sideskirt - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1064 - Exhaust Alien - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1065 - Exhaust Alien - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1066 - Exhaust X-Flow - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1067 - Roof Alien - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1068 - Roof X-Flow - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1069 - Sideskirt Right Alien Sideskirt - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1070 - Sideskirt Right X-Flow Sideskirt - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1071 - Sideskirt Left Alien Sideskirt - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1072 - Sideskirt Left X-Flow Sideskirt - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1073 - Wheels Shadow - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1074 - Wheels Mega - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1075 - Wheels Rimshine - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1076 - Wheels Wires - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1077 - Wheels Classic - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1078 - Wheels Twist - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1079 - Wheels Cutter - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1080 - Wheels Switch - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1081 - Wheels Grove - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1082 - Wheels Import - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1083 - Wheels Dollar - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1084 - Wheels Trance - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1085 - Wheels Atomic - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
				| V(554)
			},
			// 1086 - Stereo - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1087 - Hydraulics - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1088 - Roof Alien - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1089 - Exhaust X-Flow - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1090 - Sideskirt Right Alien Sideskirt - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1091 - Roof X-Flow - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1092 - Exhaust Alien - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1093 - Sideskirt Left X-Flow Sideskirt - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1094 - Sideskirt Left Alien Sideskirt - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1095 - Sideskirt Right X-Flow Sideskirt - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1096 - Wheels Ahab - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1097 - Wheels Virtual - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1098 - Wheels Access - Most cars
			{
				V(400) | V(401) | V(402) | V(404) | V(405) | V(409) | V(410) | V(411) | V(412) | V(415) | V(418) | V(419) | V(420) | V(421) | V(422) | V(424) | V(426),
				V(436) | V(438) | V(439) | V(442) | V(445) | V(451) | V(458),
				V(466) | V(467) | V(474) | V(475) | V(477) | V(478) | V(479) | V(480) | V(489) | V(491) | V(492),
				V(496) | V(500) | V(505) | V(506) | V(507) | V(516) | V(517) | V(518) | V(526) | V(527),
				V(529) | V(533) | V(534) | V(535) | V(536) | V(540) | V(541) | V(542) | V(545) | V(546) | V(547) | V(549) | V(550) | V(551) | V(555) | V(558) | V(559),
				V(560) | V(561) | V(562) | V(565) | V(566) | V(567) | V(575) | V(576) | V(579) | V(580) | V(585) | V(587) | V(589),
				V(600) | V(602) | V(603)
			},
			// 1099 - Sideskirt Left Chrome Sideskirt - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1100 - Bullbar Chrome Grill - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1101 - Sideskirt Left `Chrome Flames` Sideskirt - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1102 - Sideskirt Left `Chrome Strip` Sideskirt - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1103 - Roof Covertible - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1104 - Exhaust Chrome - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1105 - Exhaust Slamin - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1106 - Sideskirt Right `Chrome Arches` - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1107 - Sideskirt Left `Chrome Strip` Sideskirt - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1108 - Sideskirt Right `Chrome Strip` Sideskirt - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1109 - Rear Bullbars Chrome - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1110 - Rear Bullbars Slamin - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1111 - Front Sign? Little Sign? - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1112 - Front Sign? Little Sign? - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1113 - Exhaust Chrome - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1114 - Exhaust Slamin - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1115 - Front Bullbars Chrome - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1116 - Front Bullbars Slamin - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1117 - Front Bumper Chrome - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1118 - Sideskirt Right `Chrome Trim` Sideskirt - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1119 - Sideskirt Right `Wheelcovers` Sideskirt - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1120 - Sideskirt Left `Chrome Trim` Sideskirt - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1121 - Sideskirt Left `Wheelcovers` Sideskirt - Slamvan
			{
				0,
				0,
				0,
				0,
				V(535),
				0,
				0
			},
			// 1122 - Sideskirt Right `Chrome Flames` Sideskirt - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1123 - Bullbars Bullbar Chrome Bars - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1124 - Sideskirt Left `Chrome Arches` Sideskirt - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1125 - Bullbars Bullbar Chrome Lights - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1126 - Exhaust Chrome Exhaust - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1127 - Exhaust Slamin Exhaust - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1128 - Roof Vinyl Hardtop - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1129 - Exhaust Chrome - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1130 - Roof Hardtop - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1131 - Roof Softtop - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1132 - Exhaust Slamin - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1133 - Sideskirt Right `Chrome Strip` Sideskirt - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1134 - SideSkirt Right `Chrome Strip` Sideskirt - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1135 - Exhaust Slamin - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1136 - Exhaust Chrome - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1137 - Sideskirt Left `Chrome Strip` Sideskirt - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1138 - Spoiler Alien - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1139 - Spoiler X-Flow - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1140 - Rear Bumper X-Flow - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1141 - Rear Bumper Alien - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1142 - Vents Left Oval Vents - Certain Transfender Cars
			{
				V(401),
				V(439),
				V(491),
				V(496) | V(517) | V(518),
				V(540) | V(547) | V(549) | V(550),
				V(585),
				V(603)
			},
			// 1143 - Vents Right Oval Vents - Certain Transfender Cars
			{
				V(401),
				V(439),
				V(491),
				V(496) | V(517) | V(518),
				V(540) | V(547) | V(549) | V(550),
				V(585),
				V(603)
			},
			// 1144 - Vents Left Square Vents - Certain Transfender Cars
			{
				V(401),
				V(439),
				V(491),
				V(517) | V(518),
				V(540) | V(542) | V(549) | V(550),
				V(585) | V(589),
				V(603)
			},
			// 1145 - Vents Right Square Vents - Certain Transfender Cars
			{
				V(401),
				V(439),
				V(491),
				V(517) | V(518),
				V(540) | V(542) | V(549) | V(550),
				V(585) | V(589),
				V(603)
			},
			// 1146 - Spoiler X-Flow - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1147 - Spoiler Alien - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1148 - Rear Bumper X-Flow - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1149 - Rear Bumper Alien - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1150 - Rear Bumper Alien - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1151 - Rear Bumper X-Flow - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1152 - Front Bumper X-Flow - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1153 - Front Bumper Alien - Flash
			{
				0,
				0,
				0,
				0,
				0,
				V(565),
				0
			},
			// 1154 - Rear Bumper Alien - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1155 - Front Bumper Alien - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1156 - Rear Bumper X-Flow - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1157 - Front Bumper X-Flow - Stratum
			{
				0,
				0,
				0,
				0,
				0,
				V(561),
				0
			},
			// 1158 - Spoiler X-Flow - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1159 - Rear Bumper Alien - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1160 - Front Bumper Alien - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1161 - Rear Bumper X-Flow - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1162 - Spoiler Alien - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1163 - Spoiler X-Flow - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1164 - Spoiler Alien - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1165 - Front Bumper X-Flow - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1166 - Front Bumper Alien - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1167 - Rear Bumper X-Flow - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1168 - Rear Bumper Alien - Uranus
			{
				0,
				0,
				0,
				0,
				V(558),
				0,
				0
			},
			// 1169 - Front Bumper Alien - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1170 - Front Bumper X-Flow - Sultan
			{
				0,
				0,
				0,
				0,
				0,
				V(560),
				0
			},
			// 1171 - Front Bumper Alien - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1172 - Front Bumper X-Flow - Elegy
			{
				0,
				0,
				0,
				0,
				0,
				V(562),
				0
			},
			// 1173 - Front Bumper X-Flow - Jester
			{
				0,
				0,
				0,
				0,
				V(559),
				0,
				0
			},
			// 1174 - Front Bumper Chrome - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1175 - Rear Bumper Slamin - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1176 - Front Bumper Chrome - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1177 - Rear Bumper Slamin - Broadway
			{
				0,
				0,
				0,
				0,
				0,
				V(575),
				0
			},
			// 1178 - Rear Bumper Slamin - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1179 - Front Bumper Chrome - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1180 - Rear Bumper Chrome - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1181 - Front Bumper Slamin - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1182 - Front Bumper Chrome - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1183 - Rear Bumper Slamin - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1184 - Rear Bumper Chrome - Blade
			{
				0,
				0,
				0,
				0,
				V(536),
				0,
				0
			},
			// 1185 - Front Bumper Slamin - Remington
			{
				0,
				0,
				0,
				0,
				V(534),
				0,
				0
			},
			// 1186 - Rear Bumper Slamin - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1187 - Rear Bumper Chrome - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1188 - Front Bumper Slamin - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1189 - Front Bumper Chrome - Savanna
			{
				0,
				0,
				0,
				0,
				0,
				V(567),
				0
			},
			// 1190 - Front Bumper Slamin - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1191 - Front Bumper Chrome - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1192 - Rear Bumper Chrome - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			},
			// 1193 - Rear Bumper Slamin - Tornado
			{
				0,
				0,
				0,
				0,
				0,
				V(576),
				0
			}
		};
	// Check if the componentid is in range
	if (1000 <= componentid <= 1193)
	{
		new
			model = GetVehicleModel(vehicleid);
		// Check the model is in range
		// We are dealing with cheaters after all
		if (400 <= model <= 603)
		{
			// Adjust the model to the range of our array
			model -= 400;
			// This is the line that does all the work.
			// Should be very fast and efficient.
			// Uses bit manipulation instead of
			// divisions and mods of 32.
			// The other way of doing it would be:
			// return cs_bMods[((componentid - 1000) * 7) + (model >> 5)]
			// But this is probably better as it's all native.
			// Could run tests if you really wanted, but
			// that would require compressing the array
			// above into a 1d array (saving no space).
			return cs_bMods[componentid - 1000][model >> 5] & (1 << (model & 0x1F));
		}
	}
	return 0;
}
