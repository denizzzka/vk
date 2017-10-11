module vk.images;

import vkapi;
import dtiv.lib;
import dtiv.ansi;

// vkMessageLine("https://pp.userapi.com/c837435/v837435992/661cc/Isr9YKDifcg.jpg", "", false, false, false, false, 0)

void displayIfPicture(in vkMessageLine mline)
{
    import std.regex;

    auto ctr = ctRegex!(`^http(s?):\/\/.*\.(?:jpeg|jpg|gif|png)$`);

    auto mf = matchFirst(mline.text, ctr);

    if(mf.empty)
        return;

    import core.time;
    import std.stdio;

    try
    {
        auto pic = AsyncMan.httpget(mline.text, dur!"seconds"(5) /*timeout*/, 3 /*attempts*/);
        displayPic(cast(ubyte[]) pic);

        //~ assert(false, "just exit");
    }
    catch(Exception e)
    {
        writeln(e.msg);
    }
    finally
    {
        //~ writeln("picture!"); // TODO: remove it
    }
}

void displayPic(in ubyte[] b)
{
    import std.exception;

    auto img = IFImgWrapper(b);

    if(img.w > 512)
        throw new Exception("Image is too wide");

    const flags = 0;

    for (int y = 0; y < img.h - 8; y += 8)
    {
        emit_row(img, flags, y);

        import std.stdio;
        writeln("\x1b[0m \r");
    }
}

private:

struct IFImgWrapper
{
    import imageformats;

    IFImage img;
    alias img this;

    this(in ubyte[] b)
    {
        img = read_image_from_mem(b, ColFmt.RGB);
    }

    Pixel getPixel(int x, int y) const
    {
        assert (x >= 0);
        assert (y >= 0);

        const idx = (y * img.w + x) * Pixel.arr.length;

        assert(idx >= 0);
        assert(idx < img.pixels.length);

        Pixel ret;
        ret.arr = img.pixels[idx .. idx + Pixel.arr.length];

        return ret;
    }
}
