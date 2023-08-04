// D import file generated from 'source/isimd.d'
module isimd;
interface ISIMD(ulong R) if (R == 256LU || R == 512LU)
{
	protected
	{
		static nothrow bool getBuffer(T[] data, out T*[] address)
		{
			if (data == null || data.length == 0LU)
				return false;
			address = new T*[](data.length);
			foreach (n; 0LU .. data.length)
			{
				address[n] = &data[n];
			}
			return cast(ulong)address[0] % (R / 8LU) == 0LU;
		}
		static T[] setBuffer(in ulong N_c, in T[] data = null)
		{
			if (N_c > 0LU)
			{
				import core.memory : GC;
				import core.stdc.stdlib : aligned_alloc;
				ulong L__B = N_c * T.sizeof;
				void* b = aligned_alloc(R / 8LU, L__B);
				GC.addRange(b, L__B);
				T[] z = cast(T[])b[0LU..L__B];
				if (data.length == N_c)
					z[] = data[];
				return z;
			}
			else
				return null;
		}
	}
}
