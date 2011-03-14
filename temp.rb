require "zlib"

data = "Amet, porttitor quis, odio. Suspendisse cursus justo nec urna.
Suspendisse potenti. In hac habitasse platea dictumst. Cras quis lacus.
Vestibulum rhoncus congue lacus. Vivamus euismod, felis quis commodo viverra,
dolor elit dictum ante, et mollis eros augue at est. Class aptent taciti
sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Nulla
lectus sem, tristique sed, semper in, hendrerit non, sem. Vivamus dignissim
massa in ipsum. Morbi fringilla ullamcorper ligula. Nunc turpis. Mauris vitae
sapien. Nunc luctus bibendum velit.

Morbi faucibus volutpat sapien. Nam ac mauris at justo adipiscing facilisis.
Nunc et velit. Donec auctor, nulla id laoreet volutpat, pede erat."

data = Marshal.dump(data)

p data.length
compressed = Zlib::Deflate.deflate(data)
p compressed.length
p Marshal.dump(compressed).length
