using System;
using System.Collections;

namespace ElectricEel;

public class wondrous
{
	public enum ResultCode
	{
		LowDelay = -50,
		Overflow,
		Record,
		Period,
		LogPeriod,
		StartOfRun,
		EndOfRun,
		AlreadyFinished
	}

	private struct CutOff_Entry
	{
		public ulong CutOffNumber;

		public int CutOffDelay;
	}

	public delegate void CallBackReporter(int threadindex, ResultCode code, string info);

	private const int Limit = 65536;

	private const int MaxLen = 8;

	private const int OptSieveSpan = 25;

	private const int OptSieveSize = 33554432;

	private const int OptAddInnerLoop = 512;

	private const int OptSieveMaxGap = 560;

	private const int OptRunMaxNum = 4;

	private const int OptRunMaxBits = 16;

	private const int OptRunLogMask = 0;

	private const int LogPeriodicity = 4;

	private static readonly BitArray OptSieve;

	private static readonly CutOff_Entry[] CutOffs;

	private static readonly ulong OverflowIndicatorExtra;

	private static readonly int LastCutOff;

	private uint[] Number;

	private string FormatString;

	private string PureString;

	private ulong OverflowCount;

	private int LoopCount;

	private CallBackReporter CallBack;

	private int UnitID;

	private int MinShowDelay;

	static wondrous()
	{
		OptSieve = new BitArray(33554432, defaultValue: false);
		CutOffs = new CutOff_Entry[7]
		{
			new CutOff_Entry
			{
				CutOffNumber = 4578853915uL,
				CutOffDelay = 1050
			},
			new CutOff_Entry
			{
				CutOffNumber = 202485402111uL,
				CutOffDelay = 1255
			},
			new CutOff_Entry
			{
				CutOffNumber = 1444338092271uL,
				CutOffDelay = 1356
			},
			new CutOff_Entry
			{
				CutOffNumber = 3743559068799uL,
				CutOffDelay = 1443
			},
			new CutOff_Entry
			{
				CutOffNumber = 100759293214567uL,
				CutOffDelay = 1662
			},
			new CutOff_Entry
			{
				CutOffNumber = 706866561864865uL,
				CutOffDelay = 1856
			},
			new CutOff_Entry
			{
				CutOffNumber = 3586720916237671uL,
				CutOffDelay = 1874
			}
		};
		LastCutOff = 6;
		makeoptsieve();
		OverflowIndicatorExtra = 8198552921648689600uL;
	}

	public wondrous()
	{
		Number = new uint[8];
	}

	public void Start(CallBackReporter callback, int unitid, string numberstring, int loopcount = 1, int minshowdelay = 1960)
	{
		CallBack = callback;
		UnitID = unitid;
		if (loopcount > 0)
		{
			LoopCount = loopcount;
		}
		if (minshowdelay > 1200)
		{
			MinShowDelay = minshowdelay;
		}
		PureString = numberstring;
		stringtonum();
		optrunmode();
	}

	private void optrunmode()
	{
		uint[] array = new uint[8];
		int evencount = 0;
		int num = 0;
		int num2 = 0;
		uint[] array2 = new uint[4];
		Number[0] = 0u;
		Number[1] = 0u;
		numtostring();
		string info = $"{FormatString} : Start of won602 Run ({Now()})";
		CallBack(UnitID, ResultCode.StartOfRun, info);
		while (LoopCount > 0)
		{
			for (uint num3 = 1u; num3 < 33554432; num3 += 2)
			{
				if (!OptSieve[(int)num3])
				{
					continue;
				}
				Number[0] = num3 & 0xFFFF;
				Number[1] = num3 >> 16;
				do
				{
					for (int i = 0; i < 4; i++)
					{
						array2[i] = Number[i];
					}
					ResultCode resultCode = optcalcdelay(array2, MinShowDelay);
					if (resultCode == ResultCode.Period)
					{
						break;
					}
					for (int j = 0; j < 4; j++)
					{
						Number[j] = array2[j];
					}
					if (resultCode == ResultCode.Overflow)
					{
						OverflowCount++;
					}
					for (int k = 0; k < 8; k++)
					{
						array[k] = Number[k];
					}
					num = calcdelay(array, ref evencount, MinShowDelay);
					if (num >= MinShowDelay)
					{
						numtostring();
						int level = evencount - 5 * num / 8;
						showrecord(num, level);
					}
					Number[1] += 512u;
				}
				while ((long)Number[1] < 65536L);
			}
			Number[0] = 0u;
			Number[1] = 0u;
			Number[2]++;
			for (int l = 2; Number[l] >= 65536; l++)
			{
				Number[l] -= 65536u;
				Number[l + 1]++;
			}
			numtostring();
			if ((Number[2] & 0) == 0)
			{
				info = $"Current number:{FormatString} ({Now()})";
				CallBack(UnitID, ResultCode.Period, info);
				if (++num2 >= 4)
				{
					info = $"Current number: {FormatString} ({Now()}) Overflows={OverflowCount}";
					CallBack(UnitID, ResultCode.LogPeriod, info);
					num2 = 0;
					OverflowCount = 0uL;
				}
			}
			LoopCount--;
		}
		logendofrun("OptRun");
	}

	private static ResultCode optcalcdelay(uint[] orgnum, int minshowdelay)
	{
		uint num = orgnum[0];
		uint num2 = orgnum[1];
		uint num3 = orgnum[2];
		uint num4 = orgnum[3];
		try
		{
			do
			{
				ulong num5 = num + (num2 << 16);
				num5 += (ulong)(num3 + (num4 << 16)) << 32;
				if (num5 % 3 != 2 && num5 % 9 != 4)
				{
					int num6 = 0;
					int num7 = LastCutOff;
					bool flag;
					while (true)
					{
						ulong num8 = num5 & 3;
						if (num8 <= 3)
						{
							switch ((uint)num8)
							{
							case 3u:
								if (num5 > OverflowIndicatorExtra)
								{
									return ResultCode.Overflow;
								}
								num5 = (num5 << 1) + (num5 >> 2) + 2;
								num6 += 4;
								break;
							case 1u:
							case 2u:
								num5 = (num5 >> 1) + (num5 >> 2) + 1;
								num6 += 3;
								break;
							case 0u:
								num5 >>= 2;
								num6 += 2;
								break;
							}
						}
						if (num5 < CutOffs[num7].CutOffNumber)
						{
							flag = num6 + CutOffs[num7].CutOffDelay < minshowdelay;
							if (--num7 < 0 || flag)
							{
								break;
							}
						}
					}
					if (!flag)
					{
						while (true)
						{
							if ((num5 & 1) != 0)
							{
								num6 += 2;
								num5 += (num5 >> 1) + 1;
								continue;
							}
							num6++;
							num5 >>= 1;
							if (num5 <= 1)
							{
								break;
							}
						}
						if (num6 >= minshowdelay)
						{
							return ResultCode.Record;
						}
					}
				}
				num2 += 512;
			}
			while (num2 < 65536);
			return ResultCode.Period;
		}
		finally
		{
			orgnum[0] = num;
			orgnum[1] = num2;
			orgnum[2] = num3;
			orgnum[3] = num4;
		}
	}

	private static int calcdelay(uint[] num, ref int evencount, int mindelay)
	{
		int num2 = 0;
		evencount = 0;
		num2 = calculate12byte(num, ref evencount, mindelay);
		if (num2 == -49)
		{
			num2 = calculate16byte(num, ref evencount, mindelay);
		}
		return num2;
	}

	private static int calculate12byte(uint[] num, ref int evencount, int mindelay)
	{
		int num2 = 0;
		int num3 = 0;
		ulong num4 = CutOffs[4].CutOffNumber >> 32;
		int cutOffDelay = CutOffs[4].CutOffDelay;
		ulong num5 = (num[1] << 16) + num[0];
		ulong num6 = (num[3] << 16) + num[2];
		ulong num7 = (num[5] << 16) + num[4];
		while (true)
		{
			if ((num5 & 1) != 0)
			{
				num2++;
				ulong num8 = num5 + ((num6 & 1) << 32);
				ulong num9 = num6 + ((num7 & 1) << 32);
				num5 += 1 + (num8 >> 1);
				num6 += num9 >> 1;
				num7 += num7 >> 1;
				num6 += num5 >> 32;
				num5 &= 0xFFFFFFFFu;
				num7 += num6 >> 32;
				num6 &= 0xFFFFFFFFu;
				if (num7 > 9223372036854775808uL)
				{
					return -49;
				}
			}
			else
			{
				num3++;
				num5 = (num5 >> 1) + ((num6 & 1) << 31);
				num6 = (num6 >> 1) + ((num7 & 1) << 31);
				num7 >>= 1;
				if (num7 == 0L && num6 < num4)
				{
					break;
				}
			}
		}
		num3 += num2;
		if (num2 + num3 + cutOffDelay < mindelay)
		{
			return -50;
		}
		int result = num2 + num3 + calculate8bytetail(num5, num6, ref evencount);
		evencount += num3;
		return result;
	}

	private static int calculate16byte(uint[] num, ref int evencount, int mindelay)
	{
		int num2 = 0;
		int num3 = 0;
		ulong num4 = CutOffs[4].CutOffNumber >> 32;
		int cutOffDelay = CutOffs[4].CutOffDelay;
		ulong num5 = (num[1] << 16) + num[0];
		ulong num6 = (num[3] << 16) + num[2];
		ulong num7 = (num[5] << 16) + num[4];
		ulong num8 = (num[7] << 16) + num[6];
		while (true)
		{
			if ((num5 & 1) != 0)
			{
				num2++;
				ulong num9 = num5 + ((num6 & 1) << 32);
				ulong num10 = num6 + ((num7 & 1) << 32);
				ulong num11 = num7 + ((num8 & 1) << 32);
				ulong num12 = num8;
				num5 += 1 + (num9 >> 1);
				num6 += num10 >> 1;
				num7 += num11 >> 1;
				num8 += num12 >> 1;
				num6 += num5 >> 32;
				num5 &= 0xFFFFFFFFu;
				num7 += num6 >> 32;
				num6 &= 0xFFFFFFFFu;
				num8 += num7 >> 32;
				num7 &= 0xFFFFFFFFu;
			}
			else
			{
				num3++;
				num5 = (num5 >> 1) + ((num6 & 1) << 31);
				num6 = (num6 >> 1) + ((num7 & 1) << 31);
				num7 = (num7 >> 1) + ((num8 & 1) << 31);
				num8 >>= 1;
				if (num7 == 0L && num8 == 0L && num6 < num4)
				{
					break;
				}
			}
		}
		num3 += num2;
		if (num2 + num3 + cutOffDelay < mindelay)
		{
			return -50;
		}
		int result = num2 + num3 + calculate8bytetail(num5, num6, ref evencount);
		evencount += num3;
		return result;
	}

	private static int calculate8bytetail(ulong n0, ulong n1, ref int evencount)
	{
		int num = 0;
		int num2 = 0;
		while (true)
		{
			if ((n0 & 1) != 0)
			{
				num++;
				ulong num3 = n0 + ((n1 & 1) << 32);
				n0 += 1 + (num3 >> 1);
				n1 += n1 >> 1;
				n1 += n0 >> 32;
				n0 &= 0xFFFFFFFFu;
			}
			else
			{
				num2++;
				n0 = (n0 >> 1) + ((n1 & 1) << 31);
				n1 >>= 1;
				if (n1 == 0L)
				{
					break;
				}
			}
		}
		while (true)
		{
			if ((n0 & 1) != 0)
			{
				num++;
				n0 += 1 + (n0 >> 1);
				continue;
			}
			num2++;
			n0 >>= 1;
			if (n0 <= 1)
			{
				break;
			}
		}
		return num + (evencount = num2 + num);
	}

	private void logendofrun(string runstring)
	{
		numtostring();
		string info = $"{FormatString} : End of {runstring}";
		CallBack(UnitID, ResultCode.EndOfRun, info);
	}

	private void showrecord(int delay, int level)
	{
		string info = $"{FormatString} Delay = {delay} (Level {level})";
		CallBack(UnitID, ResultCode.Record, info);
	}

	private void numtostring()
	{
		uint[] array = new uint[16];
		for (int i = 0; i < 16; i++)
		{
			array[i] = 0u;
		}
		int num = 7;
		while (num > 0 && Number[num] == 0)
		{
			num--;
		}
		for (int num2 = num; num2 >= 0; num2--)
		{
			for (int j = 0; j < 16; j++)
			{
				array[j] *= 65536u;
			}
			array[0] += Number[num2];
			for (int k = 0; k < 15; k++)
			{
				array[k + 1] += array[k] / 1000;
				array[k] %= 1000u;
			}
		}
		PureString = "0";
		for (int num3 = array.GetUpperBound(0); num3 >= 0; num3--)
		{
			PureString += array[num3].ToString("000");
		}
		PureString = PureString.TrimStart('0');
		FormatString = formatnumstring(PureString);
	}

	private void stringtonum()
	{
		uint[] array = new uint[16];
		string text = "000" + PureString;
		for (int i = 0; i < 8; i++)
		{
			Number[i] = 0u;
		}
		for (int j = 0; j < 16; j++)
		{
			array[j] = 0u;
		}
		int num = 0;
		int num2 = text.Length - 4;
		while (num2 >= 0)
		{
			array[num] = Convert.ToUInt32(text.Substring(num2, 4));
			num2 -= 4;
			num++;
		}
		for (int num3 = text.Length / 4; num3 >= 0; num3--)
		{
			for (int k = 0; k < Number.Length; k++)
			{
				Number[k] *= 10000u;
			}
			Number[0] += array[num3];
			for (int l = 0; l < Number.Length - 1; l++)
			{
				Number[l + 1] += Number[l] / 65536;
				Number[l] %= 65536u;
			}
		}
	}

	private static string formatnumstring(string s)
	{
		if (s.Length <= 6)
		{
			return s;
		}
		return formatnumstring(s.Substring(0, s.Length - 6)) + "," + s.Substring(s.Length - 6);
	}

	private static string Now()
	{
		return DateTime.Now.ToString("dd-MM-yyyy HH:mm:ss");
	}

	private static void makeoptsieve()
	{
		int num = 0;
		int[] array = new int[560];
		int[] array2 = new int[560];
		for (int i = 0; i < 33554432; i++)
		{
			array[num] = 0;
			array2[num] = i;
			for (int j = 0; j < 25; j++)
			{
				if ((array2[num] & 1) > 0)
				{
					array[num]++;
					array2[num] = 3 * array2[num] + 1;
				}
				array2[num] /= 2;
			}
			if ((i & 1) > 0)
			{
				OptSieve[i] = true;
				for (int num2 = num - 1; num2 >= 0; num2--)
				{
					if (array[num] == array[num2] && array2[num] == array2[num2])
					{
						OptSieve[i] = false;
						break;
					}
				}
				if (OptSieve[i] && i > num)
				{
					for (int num3 = array.GetUpperBound(0); num3 > num; num3--)
					{
						if (array[num] == array[num3] && array2[num] == array2[num3])
						{
							OptSieve[i] = false;
							break;
						}
					}
				}
			}
			num++;
			if (num == array.Length)
			{
				num = 0;
			}
		}
		array = null;
		array2 = null;
	}
}

