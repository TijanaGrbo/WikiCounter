# Coding assignment 💪

NB! [Planning for failure is here too](https://github.com/TijanaGrbo/WikiCounter/blob/main/Planning%20for%20failure.md). Go check it out 😎


This assignment seemed completely straightforward when I read it for the first time.
However, the more I thought about it, the more potential issues I could think of:

* case-sensitive search
* exact matches
* disambiguation pages
* incomplete articles
* no matches

The list goes on.

## “Solution” nr. 1 🎖️
My biggest concern were disambiguation pages, so I decided to tackle those first. I stumbled upon an inconspicuous comment under a Stack Overflow response that suggested adding `redirects` parameter set to `true`. The time was short, since that was a part of the challenge, so I went for the low-hanging fruit. I tested the query with a couple of strings (Tolkien, Java, Apple), and it seemed to be providing me with what I needed. Spoiler: I was wrong.

Some time later, my quick word counter app was seemingly working. That is, until I searched for “Steam” and came to the disappointing conclusion that `redirects=true` sometimes works and sometimes doesn’t.

### What gives?

If there’s an established primary topic for the search term, you would have the `redirects`  object that would contain `from` and `to` properties. In that case, `redirects=true` would work in terms of returning one of the relevant articles. However, I started comparing responses for different terms, and not all of them have `redirects` property. Some terms did seem to have it, but it was an empty array.

## Solution nr. 2 🥇
So another solution is to use Opensearch API with the following or similar query structure:

https://en.wikipedia.org/w/api.php?action=opensearch&search=Apple&limit=1&namespace=0

https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exintro&explaintext&titles=Apple

Stack Overflow was my friend:

[Searching Wikipedia using the API](https://stackoverflow.com/questions/27457977/searching-wikipedia-using-the-api?rq=3)

[Get the first lines of a Wikipedia article](https://stackoverflow.com/questions/1565347/get-the-first-lines-of-a-wikipedia-article/19781754#19781754)

The first request would get a list of articles relevant to the search term (or only one, depending on the limit, among other things):

```
[
    "Apple",
    [
        "Apple"
    ],
    [
        ""
    ],
    [
        "https://en.wikipedia.org/wiki/Apple"
    ]
]
```

and the second one would use the article title extracted from the first response:

```
{
    "batchcomplete": "",
    "query": {
        "pages": {
            "18978754": {
                "pageid": 18978754,
                "ns": 0,
                "title": "Apple",
                "extract": "An apple is a round, edible fruit produced by an apple tree (Malus spp., among them the domestic or orchard apple; Malus domestica). Apple trees are cultivated worldwide and are the most widely grown species in the genus Malus. The tree originated in Central Asia, where its wild ancestor, Malus sieversii, is still found. Apples have been grown for thousands of years in Eurasia and were introduced to North America by European colonists. Apples have religious and mythological significance in many cultures, including Norse, Greek, and European Christian tradition.\nApples grown from seed tend to be very different from those of their parents, and the resultant fruit frequently lacks desired characteristics. For commercial purposes, including botanical evaluation, apple cultivars are propagated by clonal grafting onto rootstocks. Apple trees grown without rootstocks tend to be larger and much slower to fruit after planting. Rootstocks are used to control the speed of growth and the size of the resulting tree, allowing for easier harvesting.\nThere are more than 7,500 cultivars of apples. Different cultivars are bred for various tastes and uses, including cooking, eating raw, and cider or apple juice production. Trees and fruit are prone to fungal, bacterial, and pest problems, which can be controlled by a number of organic and non-organic means. In 2010, the fruit's genome was sequenced as part of research on disease control and selective breeding in apple production.\n\n"
            }
        }
    }
}
```

What’s even better about this approach is that we’re not getting an HTML dump of the article, but a plain text.

The only downside	would be making two separate network requests. And I would need more time to adapt the code to it.

That’s why I chose the third option, which was the easiest and fastest to switch to.

## Solution nr. 3 🏆

I don’t know about everyone else, but Stack Overflow is still relevant to me today. And it’s Stack Overflow I have to thank for putting this one together.

https://en.wikipedia.org/w/api.php?action=query&format=json&prop=extracts&explaintext=1&redirects=1&titles=Apple

#### Now, why would I choose this one over the first solution that had the query most similar to the one in the assignment?

Yes, it’s using `query` instead of `parse` and if my goal was to display the page in `MKWebView`, I would have probably chosen `parse`. However, since my goal is to get as clean text as possible and count the occurrences of a phrase, I’m choosing the former.

Thanks to `prop=extracts` and `explaintext=1`, I can at least work with plain text without cleaning up HTML first. I'm still not avoiding disambiguation pages, since `redirects=1` produces results similar to `redirects=true`.

Admittedly, it wouldn't have been my final choice if I wasn't prioritizing trying to stay as close as possible to the time frame given in the assignment.


Five stars, had fun ⭐️

Thanks for listening to my podcast 🎤



