#!/usr/bin/env ruby
# Lists aviation cards whose Status needs another look: statuses older than a cutoff,
# civil aircraft with no status, statuses with no date, and watch dates that have
# passed or are coming up.
#
#   ruby scripts/stale_status.rb              # six-month cutoff, today's date
#   ruby scripts/stale_status.rb 3            # three-month cutoff
#   ruby scripts/stale_status.rb 6 2027-01-01 # pretend today is 2027-01-01
#
# A watch entry sits in an aircraft group next to rows and history, and is never
# shown on the page:
#   watch:
#     - ["2026-12-16", "Asiana leaves Star Alliance; drop the tag and update the status"]

require "yaml"
require "date"

ROOT = File.expand_path("..", __dir__)
cutoff_months = (ARGV[0] || 6).to_i
today = ARGV[1] ? Date.parse(ARGV[1]) : Date.today
SOON_DAYS = 30

def month_start(text)
  y, m, d = text.split("-").map(&:to_i)
  Date.new(y, m || 1, d || 1)
end

# months are counted from the start of the month a status names, so "seen 2026-05" ages from May 1
def months_between(from, to)
  (to.year - from.year) * 12 + (to.month - from.month) - (to.day < from.day ? 1 : 0)
end

aircraft = {}
Dir[File.join(ROOT, "_data/aviation/*.yml")].sort.each do |file|
  airport = File.basename(file, ".yml")
  YAML.load_file(file).each do |photo|
    (photo["details"] || []).each do |group|
      next unless group["group"].start_with?("Aircraft")
      rows = group["rows"].to_h
      id = rows["Registration"] || rows["Serial"] || rows["Side number"]
      next unless id
      entry = aircraft[id] ||= { id: id, civil: rows.key?("Registration"), cards: [], status: nil, watch: [] }
      entry[:cards] << "#{airport}/#{photo['img'].split('/').last}"
      entry[:status] ||= rows["Status"]
      entry[:watch] |= (group["watch"] || [])
    end
  end
end

stale, undated, missing, due, soon = [], [], [], [], []
aircraft.each_value do |a|
  where = a[:cards].uniq.join(", ")
  a[:watch].each do |date, note|
    d = month_start(date)
    if d <= today then due << [d, "#{a[:id]}: #{note} (#{date}; #{where})"]
    elsif d <= today + SOON_DAYS then soon << [d, "#{a[:id]}: #{note} (#{date}; #{where})"]
    end
  end
  if a[:status].nil?
    missing << "#{a[:id]} (#{where})" if a[:civil]
    next
  end
  # a retirement is settled history; it does not go stale the way "still flying" does
  next if a[:status].start_with?("Retired")
  dates = a[:status].scan(/\b(?:19|20)\d\d-\d\d(?:-\d\d)?\b/)
  if dates.empty?
    undated << "#{a[:id]}: #{a[:status]} (#{where})"
    next
  end
  newest = dates.map { |d| month_start(d) }.max
  age = months_between(newest, today)
  stale << [age, "#{a[:id]}: #{age} months since #{newest.strftime('%Y-%m')} (#{where})"] if age >= cutoff_months
end

def section(title, lines)
  return if lines.empty?
  puts "#{title} (#{lines.size})"
  lines.each { |l| puts "  #{l}" }
  puts
end

puts "Checked #{aircraft.size} aircraft on #{today}, flagging statuses #{cutoff_months}+ months old."
puts
section("Watch dates that have passed", due.sort.map(&:last))
section("Watch dates in the next #{SOON_DAYS} days", soon.sort.map(&:last))
section("Stale statuses", stale.sort_by { |age, _| -age }.map(&:last))
section("Civil aircraft with no status", missing)
section("Statuses with no date", undated)
puts "Nothing needs attention." if [due, soon, stale, missing, undated].all?(&:empty?)
