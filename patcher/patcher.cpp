#include <iostream>
#include <fstream>
#include <vector>
#include <string.h>
#include <iomanip>

using namespace std;

int readWord(fstream& patch) {
	unsigned char data[2];
	patch.read((char*)data, 2);
	return data[0] + 256 * data[1];
}

vector<unsigned char> readBytes(fstream& patch, int len) {
	auto raw = vector<unsigned char>(len);
	patch.read((char*)raw.data(), len);
	return raw;
}

int main(int argc, char** argv) {
	if (argc < 4) {
		cout << "Usage: patcher [source file] [patch file] [destination file]" << endl;
		return 1;
	}

	fstream target;
	target.open(argv[1], ios::in | ios::binary);
	if (!target.is_open()) {
		cout << "Couldn't open input file " << argv[1] << endl;
		return 1;
	}

	fstream patch;
	patch.open(argv[2], ios::in | ios::binary);
	if (!patch.is_open()) {
		cout << "Couldn't open patch file " << argv[2] << endl;
		target.close();
		return 1;
	}

	auto targetData = vector<unsigned char>(istreambuf_iterator<char>(target), istreambuf_iterator<char>());

	auto base = readWord(patch);
	cout << "Base address $" << hex << base << endl;

	while (!(patch.peek() == ifstream::traits_type::eof())) {
		auto offset = readWord(patch);
		auto len = readWord(patch);
		auto patchBytes = readBytes(patch, len);

		auto delta = offset - base;

		char buffer[128];
		sprintf_s(buffer, 128, "Patch @$%04x (+$%04x), %d bytes", offset, delta, len);

		cout << buffer << endl;

		memcpy(&targetData[delta], &patchBytes[0], len);
	}

	patch.close();
	target.close();

	fstream dest;
	dest.open(argv[3], ios::out | ios::binary);
	if (!dest.is_open()) {
		cout << "Couldn't open destination file " << argv[3] << endl;
		return 1;
	}

	dest.write((char*)targetData.data(), targetData.size());
	dest.close();

	return 0;
}
