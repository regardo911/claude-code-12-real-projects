<!-- Chapter 4, verbatim from the book. The author's nine prompts for the weather dashboard, in the order he typed them. -->

# Chapter 4 prompts: the weather dashboard

Open Claude Code in an empty folder and paste these one at a time. Open `dashboard.html` in your browser after each one (`open dashboard.html` on a Mac, `xdg-open dashboard.html` on Linux) and look before you type the next.

## 1. The first version (ch04:45-50)

```
Build me a personal dashboard web app. Single HTML file with inline CSS and JS.
It should show current weather for New York, London, and Tokyo using the
Open-Meteo API (no API key needed). Show temperature, conditions, and a
5-day forecast for each city. Make it look modern and clean.
```

## 2. Make it usable (ch04:96-101)

```
The layout is too cramped and the colors are boring. Use a dark theme with
a grid layout. Each city should be its own card with rounded corners and
subtle shadows. Make the temperature numbers large and bold. Add weather
emoji based on conditions.
```

## 3. Daily, not hourly (ch04:121-124)

```
The 5-day forecast is showing hourly data instead of daily. Fix it to show
one entry per day with the high and low temperature.
```

## 4. Search (ch04:134-136)

```
Add a search bar at the top so I can look up weather for any city.
```

This one breaks on fast typing: the geocoding API it picks is rate-limited. Prompt 4b is the correction.

## 4b. Rate limits and debounce (ch04:144-148)

```
The geocoding is hitting rate limits. Use Open-Meteo's built-in geocoding
endpoint instead, and add a 500ms debounce to the search input so it
doesn't fire on every keystroke.
```

## 5 to 8. Polish (ch04:205-211)

```
Add a loading spinner when fetching data. Right now there's just a blank space and it looks broken.
```

```
The cards aren't aligned properly on mobile. Make it single column on screens under 768px.
```

```
Add a footer that shows when the data was last refreshed and a button to manually refresh.
```

```
Save the user's searched cities to localStorage so they persist between sessions.
```

The author timed each prompt on his run (ch04:225-235): about 90 s for prompt 1 and 15 to 60 s for the rest. Your times will differ. Write yours down if you want a number.

## When it breaks (ch04:156-199)

CORS error in the browser console (ch04:164-168):

```
The API call is blocked by CORS in the browser. Either find a CORS-friendly
alternative endpoint or add a CORS proxy. Do NOT use cors-anywhere.herokuapp.com,
it's always rate-limited.
```

Page flickers, CPU at 100% (ch04:178-182):

```
There's an infinite render loop. The page is flickering and consuming 100% CPU.
Check for setInterval calls that trigger state updates, or event listeners
that fire their own events. Add a guard condition to prevent re-entry.
```

Page loads, cards are empty, no console error (ch04:190-195):

```
The dashboard loads but all the data fields are empty. No errors in the
console. Add console.log statements to trace the API response and find
where the data path is breaking. Also make sure errors aren't being
silently caught.
```

## Deploy (ch04:247-284)

Split the file first:

```
Prepare this for deployment. Split the single HTML file into separate
index.html, styles.css, and script.js files. Add proper meta tags for
sharing on social media. Make sure all API calls use HTTPS.
```

Then drag the folder onto drop.netlify.com, or add Vercel:

```
Add a vercel.json config file so I can deploy this with `vercel` CLI.
Keep it simple, no framework, just static files.
```

```bash
npm i -g vercel
vercel
```

## Your own dashboard (the build step, ch04:312-339)

Pick one of the free APIs the chapter lists (ch04:316-321), name your folder after the project, and write your own first prompt: the data, how to show it, "single-page web app with no build tools", and one visual detail.

   - **Open-Meteo** (weather): `api.open-meteo.com`. No key. CORS-friendly. Excellent docs.
   - **CoinGecko** (crypto): `api.coingecko.com/api/v3`. Free tier, no key for basic endpoints.
   - **GitHub API** (public repos): `api.github.com`. No auth for read-only public data. 60 requests/hour unauthenticated.
   - **Open-Notify** (space): `open-notify.org`. ISS position, astronauts currently in space. Fun, dead simple.
   - **JSONPlaceholder** (fake data): `jsonplaceholder.typicode.com`. Not real data, but guaranteed to work. Good fallback if other APIs give you trouble.

Then one prompt per problem you see, a split for deploy, and a deploy. You pass when you can text the URL to someone and they see working data on their phone (ch04:339).
