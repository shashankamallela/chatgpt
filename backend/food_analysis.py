import re
from difflib import get_close_matches


LOW = 0
MEDIUM = 1
HIGH = 2
VERY_HIGH = 3

LEVEL_LABELS = {
    LOW: 'Low',
    MEDIUM: 'Medium',
    HIGH: 'High',
    VERY_HIGH: 'High',
}


def profile(sugar, acidity, stickiness, starch, protective, note, fat=LOW):
    return {
        'sugar': sugar,
        'acidity': acidity,
        'stickiness': stickiness,
        'starch': starch,
        'protective': protective,
        'note': note,
        'fat': fat,
    }


EXACT_FOOD_DATA = {
    'apple': profile(HIGH, MEDIUM, MEDIUM, LOW, HIGH, 'Fruit has fiber, but natural sugar and acidity can still affect teeth.'),
    'banana': profile(HIGH, LOW, HIGH, LOW, MEDIUM, 'Soft fruit can cling to teeth, so water after eating helps.'),
    'carrot': profile(LOW, LOW, LOW, LOW, VERY_HIGH, 'Crunchy vegetables are tooth-friendly and help stimulate saliva.'),
    'cheese': profile(LOW, LOW, LOW, LOW, VERY_HIGH, 'Cheese is calcium-rich and usually protective for teeth.', fat=MEDIUM),
    'milk': profile(MEDIUM, LOW, LOW, LOW, VERY_HIGH, 'Milk has natural sugar but also calcium and minerals.', fat=MEDIUM),
    'water': profile(LOW, LOW, LOW, LOW, VERY_HIGH, 'Water is the best drink for rinsing teeth.'),
    'coke': profile(VERY_HIGH, VERY_HIGH, LOW, LOW, LOW, 'Soda combines high sugar with strong acidity.'),
    'cola': profile(VERY_HIGH, VERY_HIGH, LOW, LOW, LOW, 'Cola combines high sugar with strong acidity.'),
    'soda': profile(VERY_HIGH, VERY_HIGH, LOW, LOW, LOW, 'Soda combines high sugar with strong acidity.'),
    'soft drink': profile(VERY_HIGH, VERY_HIGH, LOW, LOW, LOW, 'Soft drinks combine sugar and acidity.'),
    'juice': profile(HIGH, HIGH, LOW, LOW, MEDIUM, 'Juice is acidic and has concentrated natural sugar.'),
    'lemonade': profile(VERY_HIGH, VERY_HIGH, LOW, LOW, LOW, 'Lemonade is both sugary and acidic.'),
    'candy': profile(VERY_HIGH, HIGH, VERY_HIGH, LOW, LOW, 'Sticky sweets keep sugar on teeth for longer.'),
    'chocolate': profile(VERY_HIGH, LOW, HIGH, LOW, LOW, 'Chocolate is high in sugar and can cling to tooth surfaces.', fat=HIGH),
    'chips': profile(LOW, LOW, HIGH, VERY_HIGH, LOW, 'Refined starch breaks down into sugars and can stick between teeth.', fat=HIGH),
    'crisps': profile(LOW, LOW, HIGH, VERY_HIGH, LOW, 'Refined starch breaks down into sugars and can stick between teeth.', fat=HIGH),
}


KEYWORD_FOOD_DATA = [
    (
        (
            'cake', 'pie', 'baklava', 'beignet', 'pudding', 'cannoli',
            'cheesecake', 'mousse', 'churro', 'brulee', 'cup cake',
            'cupcake', 'donut', 'macaron', 'ice cream', 'panna cotta',
            'shortcake', 'tiramisu', 'waffle', 'pancake', 'toast', 'macarons'
        ),
        profile(VERY_HIGH, MEDIUM, HIGH, HIGH, LOW, 'Sweet desserts raise cavity risk because they are sugary and often sticky.', fat=HIGH),
    ),
    (
        (
            'fries', 'onion ring', 'garlic bread', 'bread', 'sandwich',
            'burger', 'hamburger', 'hot dog', 'pizza', 'nacho', 'taco',
            'quesadilla', 'burrito', 'poutine', 'bruschetta', 'croque', 
            'club', 'nachos', 'tacos'
        ),
        profile(MEDIUM, MEDIUM, HIGH, HIGH, LOW, 'Refined starches can stick to teeth and feed plaque bacteria.', fat=HIGH),
    ),
    (
        (
            'rice', 'risotto', 'paella', 'bibimbap', 'dumpling', 'gyoza',
            'dumplings', 'pad thai', 'ramen', 'ravioli', 'gnocchi', 'lasagna',
            'spaghetti', 'macaroni', 'samosa', 'spring roll', 'takoyaki', 'pho',
            'grits'
        ),
        profile(LOW, LOW, HIGH, HIGH, LOW, 'Starchy meals are moderate risk, especially if they cling between teeth.', fat=MEDIUM),
    ),
    (
        (
            'salad', 'edamame', 'hummus', 'guacamole', 'omelette',
            'deviled egg', 'miso soup', 'seaweed', 'caprese', 'caesar',
            'greek', 'beet', 'eggs', 'huevos'
        ),
        profile(LOW, LOW, LOW, LOW, VERY_HIGH, 'Vegetables, protein, and mineral-rich foods are generally tooth-friendly.'),
    ),
    (
        (
            'salmon', 'sashimi', 'sushi', 'tuna', 'scallop', 'oyster',
            'mussel', 'crab', 'lobster', 'shrimp', 'fish', 'clam',
            'chowder', 'ceviche', 'scallops', 'oysters', 'mussels', 'calamari'
        ),
        profile(LOW, MEDIUM, LOW, LOW, HIGH, 'Seafood is low in sugar; sauces or rice can add some oral-health risk.', fat=LOW),
    ),
    (
        (
            'steak', 'rib', 'pork', 'beef', 'chicken', 'duck', 'filet',
            'carpaccio', 'tartare', 'wings', 'ribs', 'mignon', 'foie', 'gras',
            'escargots', 'chop', 'curry'
        ),
        profile(LOW, LOW, MEDIUM, LOW, HIGH, 'Protein foods are low in sugar, but sticky sauces can increase risk.', fat=HIGH),
    ),
    (
        (
            'ceviche', 'hot and sour', 'tomato', 'pickle', 'vinegar',
            'orange', 'lemon', 'lime', 'onion', 'soup', 'bisque'
        ),
        profile(MEDIUM, VERY_HIGH, LOW, LOW, MEDIUM, 'Acidic foods can soften enamel temporarily.'),
    ),
    (
        (
            'fried', 'calamari', 'tempura', 'falafel'
        ),
        profile(LOW, LOW, HIGH, HIGH, LOW, 'Fried breaded foods often leave sticky starch on teeth.', fat=HIGH),
    ),
]


KNOWN_NAMES = set(EXACT_FOOD_DATA)
for keywords, _ in KEYWORD_FOOD_DATA:
    KNOWN_NAMES.update(keywords)

NOISE_WORDS = {
    'camera',
    'food',
    'image',
    'img',
    'jpeg',
    'jpg',
    'photo',
    'pic',
    'picture',
    'png',
    'scan',
    'upload',
    'webp',
}


def normalize_food_name(value):
    cleaned = str(value or '').lower().replace('_', ' ')
    cleaned = re.sub(r'[^a-z0-9\s]+', ' ', cleaned)
    return re.sub(r'\s+', ' ', cleaned).strip()


def split_food_items(food_text):
    normalized = str(food_text or '').replace('\n', ',')
    parts = re.split(r',|/|\+|\band\b', normalized, flags=re.IGNORECASE)
    return [part.strip() for part in parts if part.strip()]


def detect_food_hint(value):
    normalized = normalize_food_name(value)
    if not normalized:
        return None

    words = [
        word
        for word in normalized.split()
        if not word.isdigit() and word not in NOISE_WORDS
    ]

    if not words:
        return None

    searchable = ' '.join(words)
    for known_name in sorted(KNOWN_NAMES, key=len, reverse=True):
        if known_name in searchable:
            return known_name

    close_matches = get_close_matches(searchable, KNOWN_NAMES, n=1, cutoff=0.72)
    if close_matches:
        return close_matches[0]

    for word in words:
        if len(word) < 4:
            continue

        close_matches = get_close_matches(word, KNOWN_NAMES, n=1, cutoff=0.78)
        if close_matches:
            return close_matches[0]

    return None


def clamp(value, minimum=0, maximum=100):
    return max(minimum, min(maximum, int(round(value))))


def score_profile(item_profile):
    score = (
        8
        + item_profile['sugar'] * 18
        + item_profile['acidity'] * 16
        + item_profile['stickiness'] * 10
        + item_profile['starch'] * 8
        - item_profile['protective'] * 14
    )
    return clamp(score)


def risk_from_score(score):
    if score >= 70:
        return 'High'
    if score >= 35:
        return 'Medium'
    return 'Low'


def level_from_value(value):
    if value >= 2:
        return 'High'
    if value >= 1:
        return 'Medium'
    return 'Low'


def find_food_profile(food_name):
    normalized = normalize_food_name(food_name)

    if normalized in EXACT_FOOD_DATA:
        return normalized, EXACT_FOOD_DATA[normalized], 0.96

    for keywords, item_profile in KEYWORD_FOOD_DATA:
        for keyword in keywords:
            if keyword in normalized or normalized in keyword:
                return keyword, item_profile, 0.88

    close_matches = get_close_matches(normalized, KNOWN_NAMES, n=1, cutoff=0.78)
    if close_matches:
        matched = close_matches[0]
        if matched in EXACT_FOOD_DATA:
            return matched, EXACT_FOOD_DATA[matched], 0.74

        for keywords, item_profile in KEYWORD_FOOD_DATA:
            if matched in keywords:
                return matched, item_profile, 0.70

    fallback = profile(
        MEDIUM,
        MEDIUM,
        MEDIUM,
        MEDIUM,
        LOW,
        'No exact food profile was found, so a balanced medium-risk estimate was used.',
        fat=MEDIUM,
    )
    return normalized or 'unknown food', fallback, 0.45


def analyze_food(food_text):
    items = split_food_items(food_text)
    if not items:
        items = [food_text]

    analyzed_items = []
    for item in items:
        matched_name, item_profile, match_confidence = find_food_profile(item)
        item_score = score_profile(item_profile)
        analyzed_items.append({
            'input': item,
            'matched': matched_name,
            'score': item_score,
            'risk': risk_from_score(item_score),
            'sugar': LEVEL_LABELS[item_profile['sugar']],
            'acidity': LEVEL_LABELS[item_profile['acidity']],
            'fat': LEVEL_LABELS[item_profile['fat']],
            'confidence': round(match_confidence, 2),
            'note': item_profile['note'],
            '_profile': item_profile,
        })

    scores = [item['score'] for item in analyzed_items]
    profiles = [item['_profile'] for item in analyzed_items]
    average_score = sum(scores) / len(scores)
    max_score = max(scores)
    final_score = clamp((average_score * 0.7) + (max_score * 0.3))

    max_sugar = max(item['sugar'] for item in profiles)
    max_acidity = max(item['acidity'] for item in profiles)
    max_fat = max(item['fat'] for item in profiles)
    average_confidence = sum(item['confidence'] for item in analyzed_items) / len(analyzed_items)
    water_ml = water_recommendation_ml(final_score, max_sugar, max_acidity, max_fat)
    water_advice = water_advice_for(water_ml, max_sugar, max_acidity)
    fat_advice = fat_advice_for(max_fat)
    recommendations = recommendation_list_for(
        final_score,
        max_sugar,
        max_acidity,
        max_fat,
        water_advice,
        fat_advice,
    )

    public_items = [
        {key: value for key, value in item.items() if key != '_profile'}
        for item in analyzed_items
    ]

    return {
        'risk': risk_from_score(final_score),
        'sugar': level_from_value(max_sugar),
        'acidity': level_from_value(max_acidity),
        'fat': level_from_value(max_fat),
        'score': final_score,
        'accuracy': clamp(average_confidence * 100),
        'analysis_accuracy': round(average_confidence, 2),
        'water_ml': water_ml,
        'water_glasses': water_glasses_for(water_ml),
        'water_advice': water_advice,
        'fat_advice': fat_advice,
        'recommendations': recommendations,
        'matched_foods': public_items,
        'summary': summary_for(final_score, max_sugar, max_acidity, max_fat),
        'recommendation': recommendations[0],
    }


def summary_for(score, sugar, acidity, fat):
    risk = risk_from_score(score).lower()
    sugar_text = level_from_value(sugar).lower()
    acidity_text = level_from_value(acidity).lower()
    fat_text = level_from_value(fat).lower()
    return (
        f'This food has {risk} oral-health risk with {sugar_text} sugar, '
        f'{acidity_text} acidity, and {fat_text} fat based on the matched food profile.'
    )


def water_recommendation_ml(score, sugar, acidity, fat):
    water_ml = 250

    if score >= 70:
        water_ml += 250
    elif score >= 35:
        water_ml += 100

    if sugar >= HIGH:
        water_ml += 100

    if acidity >= HIGH:
        water_ml += 100

    if fat >= HIGH:
        water_ml += 50

    return min(750, water_ml)


def water_glasses_for(water_ml):
    glasses = water_ml / 250
    if glasses.is_integer():
        return int(glasses)
    return round(glasses, 1)


def water_advice_for(water_ml, sugar, acidity):
    glasses = water_glasses_for(water_ml)
    glass_label = 'glass' if glasses == 1 else 'glasses'
    timing = 'with or after this food'

    if acidity >= HIGH:
        timing = 'after this acidic food, then wait about 30 minutes before brushing'
    elif sugar >= HIGH:
        timing = 'after this sugary food to rinse sugar from teeth'

    return f'Drink about {water_ml} ml water ({glasses} {glass_label}) {timing}.'


def fat_advice_for(fat):
    if fat >= HIGH:
        return 'Decrease fat by choosing grilled or baked options, smaller portions of cheese/cream, and fewer fried sides.'

    if fat == MEDIUM:
        return 'Keep fat moderate by using less oil, lighter sauces, and balancing the meal with vegetables.'

    return 'Fat level looks low; keep the meal balanced with water and fiber-rich foods.'


def recommendation_list_for(score, sugar, acidity, fat, water_advice, fat_advice):
    recommendations = [water_advice]

    if score >= 70:
        recommendations.append('Avoid frequent snacking on this food; keep it with a meal and rinse afterward.')
    elif score >= 35:
        recommendations.append('Eat this with a meal instead of slowly snacking, so teeth have more recovery time.')
    else:
        recommendations.append('This is a lower-risk choice; continue regular brushing and hydration.')

    if sugar >= HIGH:
        recommendations.append('Decrease sugar by choosing unsweetened drinks or a smaller dessert portion.')

    if acidity >= HIGH:
        recommendations.append('Reduce acid exposure by avoiding sipping acidic drinks for a long time.')

    if fat >= MEDIUM:
        recommendations.append(fat_advice)

    return recommendations


def recommendation_for(score, sugar, acidity):
    if score >= 70:
        return 'Rinse with water after eating, avoid frequent snacking, and brush at the next brushing time.'

    if sugar >= HIGH or acidity >= HIGH:
        return 'Have it with a meal, drink water afterward, and wait before brushing if it was acidic.'

    return 'This is a lower-risk choice. Keep drinking water and maintain regular brushing.'
