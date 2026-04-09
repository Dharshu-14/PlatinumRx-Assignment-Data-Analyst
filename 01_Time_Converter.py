def convert_minutes(minutes):
    hours = minutes // 60
    mins = minutes % 60
    unit = "hr" if hours == 1 else "hrs"
    return f"{hours} {unit} {mins} minutes"

print(convert_minutes(130)) # Result: 2 hrs 10 minutes